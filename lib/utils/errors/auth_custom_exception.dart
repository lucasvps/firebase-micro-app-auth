import 'package:equatable/equatable.dart';

class CustomException extends Equatable implements Exception {
  final String? message;

  const CustomException({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthCustomException extends Equatable implements CustomException {
  @override
  final String? message;

  const AuthCustomException({this.message = "Ocorreu um erro inesperado."});

  @override
  List<Object?> get props => [message];
}
