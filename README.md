# nuke

Super slim, lightweight, practical state management < 250 lines of code.

[Not for the faint hearted, PRs super appreciated.]

To the point:

## Counter app

```dart
import 'package:nuke/nuke.dart';

class MyHomePage extends StatelessWidget
{
  final counter = $rx(0, ref:'ref/0');

  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body: Center
      (
        child: RX(const ['ref/:any'], (context) =>
          Text(counter.value.toString()))
          //alternatively $rx.$ref('ref/0').value
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: ()=>counter.value++,
        //alternatively $rx.$ref('ref/0').value++
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

*Where's my state?*

Hence the name.

Let's break it down:

```dart
final counter = $rx(0, ref:'ref/0');
```

- `0` is our initial value
- `ref` reference the observalbe value at 'ref/0'


```dart
//intentionally not named (aka matchers:[], builder:(context)) to keep it short
child: RX(const ['ref/:any'], (context) =>
  Text($rx.$ref('ref/0').value.toString()))
```

- the observer widget name
- a list of names / regex scopes the widget should listen to
- `$rx.$ref('ref/0').value` obtain the value by reference

`counter.value` also works, the above used for illustation purposed.


More on matchers, consider this:

```dart
final counter1 = $rx(0, ref:'ref/0');
final counter2 = $rx(0, ref:'ref/1');

@override
Widget build(BuildContext context)=>
  RX(const ['ref/0', 'ref/1'], (context)=>Container());
```

The above widget will be rebuilt whenever either `counter1` or `counter2`
change their values.

Alternatively:

```dart
@override
Widget build(BuildContext context)=>
  RX(const ['ref/:idx'], (context)=>Container());
```


References are awesome because they allow observers to be defined and acessed
anywhere within the app.

A practical example would be a "aettings" screen where value X is utilized within
the underlying widget, saving hassle of passing values between the two separate
widgets and updating each's local state.

## Banana republic multi counter app

```dart
class MyHomePage2 extends StatelessWidget
{
  final counters = {
    'x': 'y',
    'a': {
      'b': {
        'c': $rx(0, ref:'counter/0'),
        'wtf': [$rx(0, ref:'counter/1'), $rx(0, ref:'counter/2')],
      },
    }
  };

  int sum()=>
    Iterable.generate(3).map((i)=>$rx.$ref('counter/$i').value as int)
      .reduce((a,b )=>a+b);

  void increment()=>
    Iterable.generate(3).forEach((i)=>$rx.$ref('counter/$i').value++);

  MyHomePage2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body: Center
      (
        child: Wrap(spacing:20, children:
        [
          //Listens to all observables on counter/:any
          RX(const ['counter/:any'],(context) =>Text('${sum()}')),

          //Listens only to counter/1
          RX(const ['counter/1'], (context) => Text('${$rx.$ref('counter/1').value}')),

          //Listens only to counter/2
          RX(['counter/2'], (context) => Text('${$rx.$ref('counter/2').value}')),
        ],),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:increment, child: const Icon(Icons.add), ),
    );
  }
}
```

## Computed values

```dart
final counter1 = $rx(0, ref:'ref/0');
final counter2 = $rx(0, ref:'ref/1');

final sum = $cmp(['ref/0', 'ref/1'],
  ()=>$rx.$ref('ref/0').value+$rx.$ref('ref/1').value, ref:'ref/sum')
```

## Tagging
```dart
final counter1 = $rx(0, ref:'ref/0', tags:['dirty']);
final counter2 = $rx(0, ref:'ref/1', tags:['dirty']);

nuke.diposeTagged(['dirty', 'whatever'], matchAny:true)
```


## Clean up

$RX automatically cleans up  observable subscriptions, however, to dispose
observables that are no longer in use, call `nuke.dispose([ref])`.

## Pub sub

```dart
import 'package:nuke/nuke.dart';

final $n = Nuke();

//subscribe
final subKey = $n.subscribe(['topic'], (topic, data)=>print(data));

//publish
$n.publish('topic', {'foo':1});

//unsubscribe
$n.unsubscribe(subKey);
```

## What's up with the $

Just to avoid accedential conflicts and keep name conventions short.
