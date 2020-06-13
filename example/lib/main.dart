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
          builder: (context) => Text($ref('ref/0').value.toString())
        )
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: ()=>counter.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
