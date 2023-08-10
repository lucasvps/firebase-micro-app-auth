import 'package:dartz/dartz.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get_it/get_it.dart';

import 'package:micro_app_auth/utils/success/success_models.dart';

import '../../external/i_auth_repository.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../interfaces/i_recover_password_usecase.dart';

class RecoverPasswordUsecase implements IRecoverPasswordUsecase {
  @override
  Future<Either<AuthCustomException, RequestSuccess>> call({
    required String email,
  }) async {
    if (!EmailValidator.validate(email)) {
      return Left(
        AuthCustomException(
          message: 'Este email é inválido',
        ),
      );
    }

    try {
      return await GetIt.I.get<IAuthRepository>().passwordRecover(email: email);
    } on AuthCustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthCustomException());
    }
  }
}
