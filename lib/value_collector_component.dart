import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValueCollectorComponent extends StatefulWidget {
  final String title;
  final String message;
  final Function(String) onValueCollected;

  const ValueCollectorComponent({
    Key key,
    this.title,
    this.message,
    this.onValueCollected,
  }) : super(key: key);

  @override
  _ValueCollectorComponentState createState() =>
      _ValueCollectorComponentState();
}

class _ValueCollectorComponentState extends State<ValueCollectorComponent> {
  String value;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: Theme.of(context)
            .textTheme
            .title
            .copyWith(color: Theme.of(context).primaryColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
          TextField(
            keyboardType: TextInputType.numberWithOptions(),
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            onChanged: (v) {
              setState(() {
                value = v?.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Enter ${widget.title}",
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              onPressed: () {
                if (value != null && value.isNotEmpty) {
                  if (widget.onValueCollected != null) {
                    widget.onValueCollected(value);
                  }
                }
              },
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
