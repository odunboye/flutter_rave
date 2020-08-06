import 'package:equatable/equatable.dart';

class AuthFailedException extends Equatable {
  final String message = "Authentication Failed";

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class RegistrationFailedException extends Equatable {
  final String message = "User Registration Failed";

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}
