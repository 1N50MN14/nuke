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
  final counter = 0.rx|'counter';

  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)=>Scaffold
  (
    appBar: AppBar(),
    body: Center
    (
      child: $Rx(const ['counter'], (ctx)=>Text('${'counter'.get.value}'))
    ),
    floatingActionButton: FloatingActionButton
    (
      onPressed:()=>'counter'.get.value++,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
  );
}
```

*Where's my state?*

Hence the name.

Let's break it down:

```dart
final counter = 0.rx|'counter';
```

- `0` is our initial value
- `.rx` syntax sugar, makes the value observalbe
- `|` pipes values changes at specified reference
- `counter` the observable reference


```dart
$Rx(const ['counter'], (ctx)=>Text('${'counter'.get.value}')
```

- `$Rx` is the observer widget name
- `['counters']` scoped reference names/regex matches that trigger rebuilds


```dart
'counter'.get.value++
```

- `'counter'.get` syntax sugar, retreives the observable
- `value++` increment value


## Counter app ("tidy" version)

```dart
import 'package:nuke/nuke.dart';

class StateX {
  final _counter = 0.rx|'counter';
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
import 'package:nuke/nuke.dart';

class MyHomePage extends StatelessWidget
{
  final counters = {
    'x': 'y',
    'a': {
      'b': {
        'c': 0.rx|'counter/0',
        'wtf': [0.rx|'counter/1', 0.rx|'counter/2'],
      },
    }
  };

  int sum()=>
    Iterable.generate(3).map((i)=>'counter/$i'.get.value as int)
      .reduce((a,b )=>a+b);

  void increment()=>
    Iterable.generate(3).forEach((i)=>'counter/$i'.get.value++);

  MyHomePage({Key key}) : super(key: key);

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
          $Rx(const ['counter/:any'], (context) =>Text('${sum()}')),

          //Listens only to counter/1
          $Rx(const ['counter/1'], (context) => Text('${'counter/1'.get.value}')),

          //Listens only to counter/2
          $Rx(const ['counter/2'], (context) => Text('${'counter/2'.get.value}')),
        ],),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:increment, child: const Icon(Icons.add), ),
    );

  }
}
```

## Bonus!!

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

