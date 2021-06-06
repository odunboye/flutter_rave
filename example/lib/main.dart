import 'package:flutter/material.dart';
import 'package:flutter_rave/flutter_rave.dart';
import 'package:get/get.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pay Me',
              ),
              FlatButton.icon(
                onPressed: () {
                  _pay(context);
                },
                icon: Icon(Icons.email),
                label: Text("Pay"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pay(BuildContext context) {
    final _rave = RaveCardPayment(
      isDemo: true,
      encKey: "FLWSECK_TESTb9e81a056b55",
      publicKey: "FLWPUBK_TEST-617c13dff945ac75461aa9255f50ae02-X",
      transactionRef: "hvHPvKYaRuJLlJWSPWGGKUyaAfWeZKnm",
      amount: 100,
      email: "demo1@example.com",
      onSuccess: (response) {
        print("$response");
        print("Transaction Successful");
        Get.snackbar(
          'Success',
          'Transaction Successful',
          barBlur: 20,
          isDismissible: true,
          duration: Duration(seconds: 3),
        );
      },
      onFailure: (err) {
        print("$err");
        print("Transaction failed");
      },
      onClosed: () {
        print("Transaction closed");
      },
      context: context,
    );

    _rave.process();
  }
}
