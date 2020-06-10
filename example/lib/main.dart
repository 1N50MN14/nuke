import 'package:flutter/material.dart';
import 'package:nuke/nuke.dart';

void main()=>runApp(MyApp());

class MyApp extends StatelessWidget
{
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget
{
  final counter = 0.$at.$ref('ref/0');

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

//example2
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