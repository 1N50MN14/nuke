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
