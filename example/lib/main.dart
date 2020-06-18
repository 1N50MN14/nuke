import 'package:flutter/material.dart';
import 'package:nuke/nuke.dart';

void main()=>runApp(MyApp());

final $n = Nuke();

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

  final simple = $rx(0, ref:'simple/0');

  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body: Center
      (
        child: RX(const ['simple/0'],(context)=>
          Text($rx.$ref('simple/0').value.toString()))
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: ()=>simple.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
