import 'package:dartz/dartz.dart';
import 'package:micro_app_auth/utils/errors/auth_custom_exception.dart';
import 'package:micro_app_auth/utils/success/success_models.dart';

abstract class IRecoverPasswordUsecase {
  Future<Either<AuthCustomException, RequestSuccess>> call({
    required String email,
  });
}
