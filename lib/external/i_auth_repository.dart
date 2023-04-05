import 'package:dartz/dartz.dart';

import '../utils/errors/auth_custom_exception.dart';
import '../utils/success/success_models.dart';

abstract class IAuthRepository {
  Future<Either<AuthCustomException, LoginSuccess>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<AuthCustomException, LoginSuccess>> signInWithGoogle();

  Future<Either<AuthCustomException, LoginSuccess>> signInWithApple();

  Future<Either<AuthCustomException, RegisterSuccess>>
      registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<AuthCustomException, RequestSuccess>> logout();

  Future<Either<AuthCustomException, RequestSuccess>> deleteAccount();

  Future<Either<AuthCustomException, RequestSuccess>> passwordRecover({
    required String email,
  });

  Future<Either<AuthCustomException, RequestSuccess>> changePassword(
      {required String newPassword});
}
