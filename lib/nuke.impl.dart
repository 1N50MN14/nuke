import 'dart:async';
import 'package:path_to_regexp/path_to_regexp.dart';

abstract class RX<T>
{
  T _value;

  String ref;

  Function(T, T) _onChanged;

  final Nuke _instance = Nuke();

  RX(T value)
  {
    _value = value;
    _instance.registerRx(this);
  }

  set value(T value)
  {
    if(_value != value)
    {
      _onChanged(value, _value);
      _value = value;
    }
  }

  T get value => _value;

  RX<T> $ref(String ref)
  {
    this.ref = ref;
    return this;
  }

  set onChanged(Function(T, T) onChanged)=> _onChanged = onChanged;

  void dispose()
  {
    _instance.disposeRef(ref);
  }
}

class SubscriptionKey
{
  final String key;

  final Iterable<RegExp > regexp;

  SubscriptionKey(this.key, Iterable<String> match) :
    regexp = match.map((r)=>pathToRegExp(r));
}

class NukeEvent<T>
{
  final String ref;

  final Map<T,T> data;

  NukeEvent(this.ref, this.data);
}

class _NukePubSub<T>
{
  final StreamController<NukeEvent> _controller =
    StreamController<NukeEvent>.broadcast();

  final Map<SubscriptionKey, StreamSubscription> _listeners = {};

  final Set<RX<T>> _rx = {};

  bool _closed()
  {
   return _controller?.isClosed;
  }

  bool _paused(SubscriptionKey subscriptionKey)
  {
    return _listeners[subscriptionKey]?.isPaused;
  }

  SubscriptionKey subscribe(String key, Iterable<String> match,
    void Function(NukeEvent event) onData)
  {
    final subscriptionKey = SubscriptionKey(key, match);

    if(!_listeners.containsKey(subscriptionKey))
    {
      _listeners[subscriptionKey] =_controller.stream
          .where((event)=>subscriptionKey.regexp
            .where((reg)=>reg.hasMatch(event.ref)).isNotEmpty)
              .listen(onData);
    }

    return subscriptionKey;
  }

  void registerRx(RX<T> rx)
  {
    rx.onChanged = (T newValue, T oldValue)
    {
      publish(NukeEvent(rx.ref, {
        'newValue':newValue,
        'oldValue':oldValue
      }));
    };

    _rx.add(rx);
  }

  RX<T> getRx(String ref)
  {
    return _rx.firstWhere((e) => e.ref == ref);
  }

  void publish(NukeEvent event)
  {
    if(!_closed())
    {
      _controller.add(event);
    }
  }

  void pause(SubscriptionKey subscriptionKey)
  {
    if(!_paused(subscriptionKey))
    {
      _listeners[subscriptionKey].pause();
    }
  }

  void resume(SubscriptionKey subscriptionKey)
  {
    if(_paused(subscriptionKey))
    {
      _listeners[subscriptionKey].resume();
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

  void dispose(SubscriptionKey subscriptionKey)
  {
    if(_listeners.containsKey(subscriptionKey))
    {
      _listeners[subscriptionKey].cancel();
      _listeners.remove(subscriptionKey);
    }
  }

  void disposeRef(String ref)
  {
    _listeners.keys.where((sKey)=>sKey.regexp
      .where((reg)=>reg.hasMatch(ref)).isNotEmpty)
        .map((sKey)=>sKey).toList()
          .forEach((sKey)=>dispose(sKey));
  }

  void disposeAll()
  {
    _listeners.keys.forEach((key)=>dispose(key));

    if(!_closed())
    {
      _controller?.close();
    }
  }
}

class Nuke extends _NukePubSub
{
  static final Nuke _instance = Nuke._internal();

  factory Nuke() => _instance;

  Nuke._internal();
}

//leaving it on <T> for now, collections/whatever easily mapped manually
class NukeRx<T> extends RX<T>
{
  NukeRx(T value) : super(value);
}

extension XrX<T> on T
{
  RX<T> get $at => NukeRx<T>(this);
}

class $ref<T>
{
  static final Nuke _instance = Nuke();

  final String ref;

  final RX<T> rx;

  static final Map<String, $ref> _cache = <String, $ref>{};

  factory $ref(String ref)
  {
    if(_cache.containsKey(ref))
    {
      return _cache[ref] as $ref<T>;
    } else {
      final $ref _ref = $ref._internal(ref);
      _cache[ref] = _ref;
      return _ref as $ref<T>;
    }
  }

  $ref._internal(this.ref) : rx = _instance.getRx(ref) as RX<T>;

  set value(T value) => rx.value = value;

  T get value => rx.value;
}