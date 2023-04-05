import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:micro_app_auth/utils/errors/auth_custom_exception.dart';
import '../../external/i_auth_repository.dart';
import '../../utils/success/success_models.dart';
import '../interfaces/i_login_usecase.dart';

class LoginUsecase implements ILoginUsecase {
  @override
  Future<Either<AuthCustomException, LoginSuccess>> call({
    required String email,
    required String password,
  }) async {
    try {
      return await GetIt.I.get<IAuthRepository>().loginWithEmailAndPassword(
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
