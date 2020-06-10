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
  final counter = 0.$at.$ref('ref/0'); //<-- more on $ref below

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
          matchers: const ['ref/0'],
          builder: (context) => Text($ref('ref/0').value.toString())
        )
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: ()=>$ref('ref/0').value++,
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
final counter = 0.$at.$ref('ref/0');
```

- `0` is our initial value
- `.$at.$ref` syntax sugar, makes the value observalbe, referenced at 'ref/0'


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


```dart
$ref('ref/0').value++
```

- Obtain and increment the value by its reference

More on matchers, consider this:

```dart
final counter1 = 0.$at.$ref('ref/0');
final counter2 = 0.$at.$ref('ref/1');

@override
Widget build(BuildContext context)=>
  $RX(matchers: const ['ref/:any'], builder(_)=>Container());
```

The above widget will be rebuilt whenever either `counter1` or `counter2`
change their values.



## Counter app ("class"/whatever version)

You can also use Nuke the old fashioned way, using references or the combination
of both. Rerferences make most sense in deeply nested objects and collections as
illustrated in the multi counter app example below.

```dart
import 'package:nuke/nuke.dart';

class StateX
{
  final _counter = 0.$at.$ref('ref/0');
  int get counter => _counter.value;
  void increment() => _counter.value++;
}

class MyHomePage extends StatelessWidget
{
  final state = StateX();

  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)=>Scaffold
  (
    appBar: AppBar(),
    body: Center
    (
      child: $Rx(const ['counter'], (ctx)=>Text('${state.counter}'))
    ),
    floatingActionButton: FloatingActionButton
    (
      onPressed:state.incement
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
  );
}
```

## Banana republic multi counter app

```dart
class MyHomePage2 extends StatelessWidget
{
  final counters = {
    'x': 'y',
    'a': {
      'b': {
        'c': 0.$at.$ref('counter/0'),
        'wtf': [0.$at.$ref('counter/1'), 0.$at.$ref('counter/2')],
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

## Bonus

```dart
import 'package:nuke/nuke.dart';

final pubsub = Nuke(); //OR Provider.of<Nuke>(context);

final sub = pubsub.subscribe('subId', ['topic/:id'], (event)=>print(event.data));

pubsub.publish(NukeEvent('topic/xyz', {'foo':'bar'}));

pubsub.pause(sub);

pubsub.resume(sub);

pubsub.dispose(sub);
}
```

