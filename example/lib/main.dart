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

  final subKey = $n.subscribe(['topic'],
    (topic, data)=>debugPrint(data.toString()),key:'xxx');

  final xx = $n.subscribe(['topic-once'], (topic, data)
  {
    debugPrint(data.toString());
  });

  MyHomePage({Key key}) : super(key: key);

  void testPubSub()
  {
    //publish
    [1].forEach((i)
    {
      $n.publish('topic', {'num':'topic $i'});
      $n.publish('topic-once', {'num':'topic-once $i'});
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body: Center
      (
        child: $RX
        (
          matchers: const ['simple/0'],
          builder: (context) => Text($ref('simple/0').value.toString())
        )
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: () async
        {
          testPubSub();
          await Future.delayed(const Duration(milliseconds: 500));
          $n.unsubscribe(xx);
          simple.value++;
          //testPubSub();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
