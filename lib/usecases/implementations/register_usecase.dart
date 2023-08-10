import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import 'package:micro_app_auth/utils/success/success_models.dart';

import '../../external/i_auth_repository.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../interfaces/i_register_usecase.dart';

class RegisterUsecase implements IRegisterUsecase {
  @override
  Future<Either<AuthCustomException, RegisterSuccess>> call({
    required String email,
    required String password,
  }) async {
    try {
      return await GetIt.I.get<IAuthRepository>().registerWithEmailAndPassword(
            email: email,
            password: password,
          );
    } on AuthCustomException catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(AuthCustomException());
    }
  }
}
