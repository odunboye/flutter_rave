//library flutter_rave;

part of "flutter_rave.dart";

typedef Widget RaveWidgetBuilder(
  BuildContext context,
  VoidCallback processCard,
);

class RaveProvider extends StatefulWidget {
  final RaveWidgetBuilder builder;
  final CreditCardInfo cardInfo;
  final List<Map<String, dynamic>> subaccounts;
  final String publicKey;
  final String encKey;
  final String transactionRef;
  final double amount;
  final String email;
  final Function onSuccess;
  final Function onFailure;
  final bool isDemo;
  final bool isPreAuth;

  RaveProvider({
    Key key,
    this.builder,
    this.isDemo = false,
    this.isPreAuth,
    @required this.cardInfo,
    @required this.publicKey,
    @required this.encKey,
    this.subaccounts,
    this.transactionRef,
    this.amount,
    this.email,
    this.onSuccess,
    this.onFailure,
  }) : super(key: key);

  @override
  _RaveProviderState createState() => _RaveProviderState();
}

class _RaveProviderState extends State<RaveProvider> {
  RaveApiService _raveService = RaveApiService.instance;

  static const AUTH_PIN = "PIN";
  static const ACCESS_OTP = "ACCESS_OTP";
  static const NOAUTH_INTERNATIONAL = "NOAUTH_INTERNATIONAL";
  static const AVS_VBVSECURECODE = "AVS_VBVSECURECODE";
  RaveInAppLocalhostServer localhostServer;

  bool isProcessing = false;
  bool webhookSuccess = false;
  bool canContinue = false;
  Map<String, dynamic> responseResult;

  Route verificationRoute;
  BuildContext verificationRouteContext;

  @override
  void initState() {
    super.initState();
    this.webhookSuccess = false;
    this.canContinue = false;
    this.responseResult = null;
    verificationRoute = null;
    _startServer();
  }

  _startServer() async {
    localhostServer = RaveInAppLocalhostServer(
      onResponse: this.onRaveFeedback,
    );
    await localhostServer.start();
  }

  @override
  void dispose() {
    this.webhookSuccess = false;
    this.canContinue = false;
    this.responseResult = null;
    verificationRoute = null;
    localhostServer.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          child: widget.builder(context, processCard),
        ),
        isProcessing
            ? OverlayLoaderWidget()
            : Container(
                width: 0,
                height: 0,
              ),
      ],
    );
  }

  Future<Map<String, dynamic>> processCard({
    String suggestedAuth,
    String redirectUrl = "http://127.0.0.1:8184", //
    // String redirectUrl = "https://vapulus.serveo.net/payment/receivepayment",
    String suggestedAuthValue,
    Map<String, String> billingAddressInfo,
  }) async {
    try {
      if (widget.cardInfo == null) return null;
      if (!widget.cardInfo.isComplete) return null;

      String authValue;

      setState(() {
        isProcessing = true;
      });

      var response = await _raveService.startChargeCard(
        widget.cardInfo,
        widget.publicKey,
        widget.encKey,
        email: widget.email,
        isProduction: !widget.isDemo,
        transactionReference: widget.transactionRef,
        amount: widget.amount,
        redirectUrl: redirectUrl,
        suggestedAuth: suggestedAuth,
        suggestedAuthValue: suggestedAuthValue,
        billingAddressInfo: billingAddressInfo,
        subaccounts: widget.subaccounts,
        isPreAuth: widget.isPreAuth,
      );

      setState(() {
        isProcessing = false;
      });

      if (response["message"] == "AUTH_SUGGESTION") {
        if (response["data"]["suggested_auth"] == AUTH_PIN) {
          authValue = await _getAuthValue(response["data"]["suggested_auth"]);

          setState(() {
            isProcessing = false;
          });

          return processCard(
            suggestedAuth: response["data"]["suggested_auth"],
            suggestedAuthValue: authValue,
          );
        }

        if (response["data"]["suggested_auth"] == AVS_VBVSECURECODE ||
            response["data"]["suggested_auth"] == NOAUTH_INTERNATIONAL) {
          final additionalPayload = await _collectAddressDetails();

          setState(() {
            isProcessing = false;
          });

          return processCard(
            suggestedAuth: response["data"]["suggested_auth"],
            suggestedAuthValue: null,
            billingAddressInfo: additionalPayload,
          );
        }
      }

      if (response["message"] == "V-COMP" &&
          response["data"]["chargeResponseCode"] == "02") {
        if (response["data"]["authModelUsed"] == ACCESS_OTP) {
          final otp = await _getAuthValue(
            "OTP",
            response["data"]["chargeResponseMessage"],
          );

          try {
            setState(() {
              isProcessing = true;
            });
            final r = await _raveService.validateTransaction(
              response["data"]["flwRef"],
              otp,
              widget.publicKey,
              !widget.isDemo,
            );

            setState(() {
              isProcessing = false;
            });
            return r;
          } catch (e) {
            setState(() {
              isProcessing = false;
            });
            rethrow;
          }
        } else if (response["data"]["authModelUsed"] == "PIN") {
          final otp = await _getAuthValue(
            "OTP",
            response["data"]["chargeResponseMessage"],
          );

          try {
            setState(() {
              isProcessing = true;
            });
            final r = await _raveService.validateTransaction(
              response["data"]["flwRef"],
              otp,
              widget.publicKey,
              !widget.isDemo,
            );

            setState(() {
              isProcessing = false;
            });
            return r;
          } catch (e) {
            setState(() {
              isProcessing = false;
            });
            rethrow;
          }
        } else if (response["data"]["authModelUsed"] == "VBVSECURECODE") {
          final uri = Uri.parse(response["data"]["authurl"]);
          var raveVerificationData;

          verificationRoute = MaterialPageRoute<Map<String, dynamic>>(
            builder: (c) {
              verificationRouteContext = c;

              return WebviewScaffold(
                url: uri.toString(),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  shape: Border(
                    bottom: BorderSide(
                      color: Colors.grey[500],
                    ),
                  ),
                  iconTheme: IconThemeData(
                    color: Colors.grey[600],
                  ),
                  title: const Text(
                    'Card Verification',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
                withZoom: false,
                withLocalStorage: true,
                withJavascript: true,
                hidden: true,
                initialChild: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            },
            fullscreenDialog: true,
          );
          await Navigator.of(context).push(verificationRoute);

          if (!webhookSuccess) {
            throw "Failed to process transaction $uri";
          }
          raveVerificationData = responseResult;

          if (raveVerificationData != null &&
              raveVerificationData["chargeResponseCode"].toString() == "00") {
            setState(() {
              isProcessing = false;
            });

            return raveVerificationData;
          }
        }
      }

      if (response["message"] == "V-COMP" &&
          response["data"]["chargeResponseCode"] == "00") {
        setState(() {
          isProcessing = false;
        });

        return response;
      }

      setState(() {
        isProcessing = false;
      });

      return null;
    } catch (e) {
      if (mounted) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("${e.toString()}"),
            duration: Duration(
              seconds: 5,
            ),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isProcessing = false;
        });
      }
      rethrow;
    }
  }

  Future<String> _getAuthValue(String response, [String message]) async {
    final _value = await _showValueModal(
      title: response,
      message: message ?? "Please provide your $response",
    );

    return _value;
  }

  Future<String> _showValueModal({String title, String message}) async {
    String value = await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return ValueCollectorComponent(
            title: title,
            message: message,
            onValueCollected: (value) {
              Navigator.of(
                c,
                rootNavigator: true,
              ).pop(value);
            });
      },
    );

    return value;
  }

  Future<Map<String, String>> _collectAddressDetails() async {
    return await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute<Map<String, String>>(
        builder: (c) => BillingInfoProvider(),
        fullscreenDialog: true,
      ),
    );
  }

  onRaveFeedback(Map<String, dynamic> feedback) {
    if (feedback != null && feedback.containsKey("response")) {
      this.responseResult = json.decode(feedback["response"]);
      this.canContinue = true;
      this.webhookSuccess = true;

      if (verificationRoute != null && verificationRouteContext != null) {
        Navigator.of(verificationRouteContext).pop(this.responseResult);
      }

      setState(() {});
    }
  }
}
