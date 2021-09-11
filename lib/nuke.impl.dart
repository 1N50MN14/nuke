import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:uuid/uuid.dart';

class RX<T>
{
  T? _value;

  String? _ref;

  List<String>? tags = [];

  late Function(T?, T?) _onChanged;

  final Nuke _instance = Nuke();

  RX(T value, {String? ref, this.tags})
  {
    _ref = ref;
    _value = value;
    _instance.registerRx(this);
  }

  set value(T? value)
  {
    if(_value != value)
    {
      _onChanged(value, _value);
      _value = value;
    }
  }

  String get ref => _ref ?? '';

  T? get value => _value;

  set onChanged(Function(T?, T?) onChanged)=> _onChanged = onChanged;

  void disposeSubs()
  {
    _instance.disposeRefSubscribers(ref);
  }
}

class SubscriptionKey extends Equatable
{
  final String key;

  final Iterable<RegExp> regexp;

  SubscriptionKey(this.key, Iterable<String> match) :
    regexp = match.map((r)=>pathToRegExp(r));


  @override
  List<Object> get props => [key, regexp.toString()];

  @override
  bool get stringify => true;
}

class NukeEvent<T>
{
  final String? ref;

  final Map<T,T> data;

  NukeEvent(this.ref, this.data);
}

class _NukePubSub<T>
{
  final Uuid _uuid = const Uuid();

  final StreamController<NukeEvent> _controller =
    StreamController<NukeEvent>.broadcast();

  final Map<SubscriptionKey, StreamSubscription> _listeners = {};

  final Set<RX<T>> _rx = {};

  bool _closed()
  {
   return _controller.isClosed;
  }

  bool? _paused(SubscriptionKey subscriptionKey)
  {
    return _listeners[subscriptionKey]?.isPaused;
  }

  void registerRx(RX<T> rx)
  {
    rx.onChanged = (T? newValue, T? oldValue)
    {
      if(!_closed())
      {
        publish(rx.ref, {'newValue':newValue, 'oldValue':oldValue});
      }
    };

    _rx.add(rx);
  }

  RX<T> getRx(String ref)
  {
    return _rx.firstWhere((e) => e.ref == ref);
  }

  void publish(String? ref, Map data)
  {
    if(!_closed())
    {
      _controller.add(NukeEvent(ref, data));
    }
  }

  SubscriptionKey subscribe(Iterable<String> match,
    void Function(String? ref, Map<T?,T?> data) onData, {String? key})
  {
    final subscriptionKey = SubscriptionKey(key ?? _uuid.v4(), match);

    if(!_listeners.containsKey(subscriptionKey))
    {
      _listeners[subscriptionKey] =_controller.stream
          .where((event)=>subscriptionKey.regexp
            .where((reg)=>reg.hasMatch(event.ref!)).isNotEmpty)
              .listen((NukeEvent event)=>
                onData(event.ref, event.data as Map<T?,T?>));
    }

    return subscriptionKey;
  }

  void unsubscribe(SubscriptionKey? subscriptionKey)
  {
    if(_listeners.containsKey(subscriptionKey))
    {
      _listeners[subscriptionKey!]?.cancel();
      _listeners.remove(subscriptionKey);
    }
  }


  void pause(SubscriptionKey subscriptionKey)
  {
    if(!_paused(subscriptionKey)!)
    {
      _listeners[subscriptionKey]?.pause();
    }
  }

  void resume(SubscriptionKey subscriptionKey)
  {
    if(_paused(subscriptionKey)!)
    {
      _listeners[subscriptionKey]?.resume();
    }
  }

  void pauseAll()
  {
    _listeners.keys.forEach((key)=>pause(key));
  }

  void resumeAll()
  {
    _listeners.keys.forEach((key)=>resume(key));
  }

  void disposeRefSubscribers(String? ref)
  {
    if(ref != null)
    {
      _listeners.keys.where((sKey)=>sKey.regexp
        .where((reg)=>reg.hasMatch(ref)).isNotEmpty)
          .map((sKey)=>sKey).toList()
            .forEach((sKey)=>unsubscribe(sKey));
    }
  }

  void dispose(Iterable<String?> refs)
  {
    refs.forEach((ref)
    {
      $rx.dispose(ref);
      disposeRefSubscribers(ref);
    });
  }

  void disposeTagged(List tags, {bool matchAny = false})
  {

    final Set _tags = Set.from(tags);

    dispose(_rx.where((el)
    {
      if(el.tags == null)
      {
        return false;
      } else {

        final len = _tags.intersection(Set.from(el.tags!)).length;

        final bool match = matchAny ? len>0 : len > tags.length;

        return match;
      }
    }).map((e) => e.ref).toList());
  }

  void unsubscribeAll()
  {
    _listeners.keys.forEach((key)=>unsubscribe(key));

    if(!_closed())
    {
      _controller.close();
    }
  }
}

class Nuke extends _NukePubSub
{
  static final Nuke _instance = Nuke._internal();

  factory Nuke() => _instance;

  Nuke._internal();
}

class $rx<T> extends RX<T>
{
  //$rx(T val, {String ref}) : super(val, ref:ref);
  static final Map<String?, $rx> _cache = <String?, $rx>{};

  static void dispose(String? ref)
  {
    _cache.remove(ref);
  }

  factory $rx(T val, {String? ref, List<String>? tags})
  {
    if(_cache.containsKey(ref))
    {
      return _cache[ref] as $rx<T>;
    } else {
      final $rx<T> _rx = $rx._internal(val, ref:ref, tags:tags);
      _cache[ref] = _rx;
      return _rx;
    }
  }

  factory $rx.$ref(String ref)
  {
    return _cache[ref] as $rx<T>;
  }

  factory $rx.$refElse(String ref, T val, {List<String>? tags})
  {
    final $rx<T?>? _rx = _cache[ref] as $rx<T?>?;

    return _rx as $rx<T>? ?? $rx(val, ref:ref, tags:tags);
  }

  $rx._internal(T val, {String? ref, List<String>? tags}) : super(val, ref:ref, tags:tags);
}

class $cmp<T> extends RX<T?>
{
  Iterable<String> refs;

  final Function fn;

  SubscriptionKey? _subKey;

  $cmp(this.refs, this.fn, {String? ref}) : super(fn() as T?, ref:ref)
  {
    _subKey = _instance.subscribe(refs, (_ref, _data)=>value=fn() as T?);
  }

  @override
  T? get value => fn() as T?;

  void dispose()
  {
    _instance.unsubscribe(_subKey);
  }
}

