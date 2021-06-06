import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/assets.dart';

class BillingInfoProvider extends StatefulWidget {
  @override
  _BillingInfoProviderState createState() => _BillingInfoProviderState();
}

class _BillingInfoProviderState extends State<BillingInfoProvider> {
  GlobalKey<FormState> _globalKey = GlobalKey();

  String billingzip = "";
  String billingcity = "";
  String billingaddress = "";
  String billingstate = "";
  String billingcountry = "";

  Future<List<Map<String, dynamic>>> countries;

  Map<String, dynamic> selectedCountry;
  Map<String, dynamic> selectedState;

  @override
  void initState() {
    super.initState();

    countries = fetchCountries(context);
  }

  List<Map<String, dynamic>> parseCountries(String responseBody) {
    final decoded = json.decode(responseBody);
    final parsed = (decoded as List<dynamic>)
        .map((i) => (i as Map<String, dynamic>))
        .toList();
    return parsed;
  }

  Future<List<Map<String, dynamic>>> fetchCountries(
      BuildContext context) async {
    try {
      final response = await rootBundle.loadString(Assets.jsonCountries);

      return parseCountries(response); // compute(, response);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: _globalKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Provide your Billing details",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Your billings details are required to validate your card",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  textInputAction: TextInputAction.continueAction,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Address is required";
                  },
                  onSaved: (v) {
                    setState(() {
                      billingaddress = v;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Address",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: countries,
                    builder: (context, snapshot) {
                      return DropdownButton<Map<String, dynamic>>(
                        items: !snapshot.hasData
                            ? []
                            : snapshot.data
                                .map(
                                  (i) => DropdownMenuItem<Map<String, dynamic>>(
                                    value: i,
                                    child: Text(
                                      i["name"],
                                    ),
                                  ),
                                )
                                .toList(),
                        hint: Text("Select Country"),
                        value: selectedCountry,
                        onChanged: (item) {
                          setState(() {
                            selectedCountry = item;
                            billingcountry = item["code2"];
                          });
                        },
                      );
                    }),
                SizedBox(
                  height: 15,
                ),
                DropdownButton<Map<String, dynamic>>(
                  items: selectedCountry == null
                      ? []
                      : (selectedCountry["states"] as List<dynamic>)
                          .map((i) => (i as Map<String, dynamic>))
                          .map((i) => DropdownMenuItem<Map<String, dynamic>>(
                                value: i,
                                child: Text(
                                  i["name"],
                                ),
                              ))
                          .toList(),
                  hint: Text("Select State"),
                  value: selectedState,
                  onChanged: (item) {
                    setState(() {
                      selectedState = item;
                      billingstate = item["code"];
                    });
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  textInputAction: TextInputAction.continueAction,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Name is required";
                  },
                  onSaved: (v) {
                    setState(() {
                      billingcity = v;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Your City Code",
                    helperText: "Example: LA",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  textInputAction: TextInputAction.continueAction,
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Zip Code is required";
                  },
                  onSaved: (v) {
                    setState(() {
                      billingzip = v;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Zip Code",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                FlatButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    _globalKey.currentState.save();
                    if (_globalKey.currentState.validate()) {
                      Navigator.of(context).pop({
                        "billingaddress": billingaddress,
                        "billingcountry": billingcountry,
                        "billingzip": billingzip,
                        "billingstate": billingstate,
                        "billingcity": billingcity,
                      });
                    }
                  },
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
