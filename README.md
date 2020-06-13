# nuke

Coming from a "backend" world where pieces of code are small, light and
modular; all things "State Mangement" in app land have been a constant
PITA for a newbie like me. Code generators, builders, pattern X, pattern Y,
loop strategies and what have you not to the sound of CPU fan throttling.

Lo and behold, a lightweight state management < 220 lines of code.

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
        child: $RX
        (
          matchers: const ['ref/:any'],
          builder: (context) => Text(counter.value.toString())
          //alternatively $ref('ref/0').value
        )
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: ()=>counter.value++,
        //alternatively $ref('ref/0').value++
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
child: $RX
(
  matchers: const ['ref/:any'],
  builder: (context) => Text($ref('ref/0').value.toString())
)
```

- `$RX` is the observer widget name
- `matchers` a list of names / regex scopes the widget should listen to
- `$ref('ref/0').value` obtain the value by reference

`counter.value` also works, the above used for illustation purposed.


More on matchers, consider this:

```dart
final counter1 = $rx(0, ref:'ref/0');
final counter2 = $rx(0, ref:'ref/1');

@override
Widget build(BuildContext context)=>
  $RX(matchers: const ['ref/0', 'ref/1'], builder(_)=>Container());
```

The above widget will be rebuilt whenever either `counter1` or `counter2`
change their values.

Alternatively:

```dart
@override
Widget build(BuildContext context)=>
  $RX(matchers: const ['ref/:idx'], builder(_)=>Container());
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
    Iterable.generate(3).map((i)=>$ref('counter/$i').value as int)
      .reduce((a,b )=>a+b);

  void increment()=>
    Iterable.generate(3).forEach((i)=>$ref('counter/$i').value++);

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
          $RX(matchers: const ['counter/:any'], builder: (context) =>Text('${sum()}')),

          //Listens only to counter/1
          $RX(matchers: const ['counter/1'], builder: (context) => Text('${$ref('counter/1').value}')),

          //Listens only to counter/2
          $RX(matchers: const ['counter/2'], builder:(context) => Text('${$ref('counter/2').value}')),
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
  ()=>$ref('ref/0').value+$ref('ref/1').value, ref:'ref/sum')
```

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
