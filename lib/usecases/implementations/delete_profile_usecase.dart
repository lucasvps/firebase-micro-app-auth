import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import '../../external/i_auth_repository.dart';
import '../../utils/errors/auth_custom_exception.dart';
import '../../utils/success/success_models.dart';
import '../interfaces/i_delete_profile_usecase.dart';

class DeleteProfileUsecase implements IDeleteProfileUsecase {
  @override
  Future<Either<AuthCustomException, RequestSuccess>> call() async {
    try {
      return await GetIt.I.get<IAuthRepository>().deleteAccount();
    } on AuthCustomException catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(AuthCustomException());
    }
  }
}
