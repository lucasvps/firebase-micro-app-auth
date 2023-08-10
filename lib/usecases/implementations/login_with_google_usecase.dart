import 'package:flutter/foundation.dart';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import 'package:micro_app_auth/usecases/interfaces/i_usecases.dart';
import 'package:micro_app_auth/utils/authentication.dart';

import '../../../utils/success/success_models.dart';
import '../../external/i_auth_repository.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../interfaces/i_login_with_google_usecase.dart';

class LoginWithGoogleUsecase implements ILoginWithGoogleUsecase {
  @override
  Future<Either<AuthCustomException, LoginSuccess>> call() async {
    try {
      return await GetIt.I.get<IAuthRepository>().signInWithGoogle();
    } on AuthCustomException catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return Left(e);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return Left(AuthCustomException());
    }
  }
}
