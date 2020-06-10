import 'package:flutter/widgets.dart';
import 'nuke.impl.dart';

class $RX extends StatefulWidget
{
  final Iterable<String> matchers;

  @required final Widget Function(BuildContext context, ) builder;

  const $RX({this.matchers, this.builder, Key key, })
    : super(key: key);

  @override _NukeWidgetState createState() => _NukeWidgetState();
}

class _NukeWidgetState extends State<$RX>
{
  final _instance = Nuke();

  SubscriptionKey subscriptionKey;

  @override
  void initState()
  {
    super.initState();

    subscriptionKey = _instance.subscribe(widget.key.toString(),
      widget.matchers ?? [], (event) => setState(() {}));
  }

  @override
  Widget build(BuildContext context)
  {
    return widget.builder(context);
  }

  @override
  void dispose()
  {
    _instance.dispose(subscriptionKey);
    super.dispose();
  }
}
