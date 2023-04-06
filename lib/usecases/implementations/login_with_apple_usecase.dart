import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import '../../../utils/success/success_models.dart';
import '../../external/i_auth_repository.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../interfaces/i_login_with_apple_usecase.dart';

class LoginWithAppleUsecase implements ILoginWithAppleUsecase {
  @override
  Future<Either<AuthCustomException, LoginSuccess>> call() async {
    try {
      return await GetIt.I.get<IAuthRepository>().signInWithApple();
    } on AuthCustomException catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(AuthCustomException());
    }
  }
}
