import 'package:flutter/widgets.dart';
import 'nuke.impl.dart';

class $Rx extends StatefulWidget
{
  final Iterable<String> match;

  final Widget Function(BuildContext context, ) builder;

  const $Rx(this.match, this.builder, {Key key, })
    : super(key: key);

  @override _NukeWidgetState createState() => _NukeWidgetState();
}

class _NukeWidgetState extends State<$Rx>
{
  final _instance = Nuke();

  SubscriptionKey subscriptionKey;

  @override
  void initState()
  {
    super.initState();

    subscriptionKey = _instance.subscribe(widget.key.toString(),
      widget.match, (event) => setState(() {}));
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
