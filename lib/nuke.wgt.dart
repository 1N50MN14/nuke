import 'package:flutter/widgets.dart';
import 'nuke.impl.dart';

class RX extends StatefulWidget
{
  final Iterable<String> matchers;

  @required final Widget Function(BuildContext context, ) builder;

  const RX(this.matchers, this.builder, {Key key} )
    : super(key: key);

  @override _NukeWidgetState createState() => _NukeWidgetState();
}

class _NukeWidgetState extends State<RX>
{
  final _instance = Nuke();

  SubscriptionKey subscriptionKey;

  @override
  void initState()
  {
    super.initState();

    final _matchers = widget.matchers.where((m) =>m!=null);

    if(_matchers.isNotEmpty)
    {
      subscriptionKey = _instance.subscribe(widget.matchers.where((m) =>m!=null),
        (_ref, _data) => setState(() {}),
        key:widget.hashCode.toString()
      );
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return widget.builder(context);
  }

  @override
  void dispose()
  {
    if(subscriptionKey != null)
    {
      _instance.unsubscribe(subscriptionKey);
    }
    super.dispose();
  }
}
