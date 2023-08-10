import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../external/i_auth_repository.dart';
import '../../utils/authentication.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../../utils/success/success_models.dart';
import '../interfaces/i_logout_usecase.dart';

class LogoutUsecase implements ILogoutUsecase {
  @override
  Future<Either<AuthCustomException, RequestSuccess>> call() async {
    try {
      Authentication.saveToken("");
      Authentication.logout();
      return await GetIt.I.get<IAuthRepository>().logout();
    } on AuthCustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthCustomException());
    }
  }
}
