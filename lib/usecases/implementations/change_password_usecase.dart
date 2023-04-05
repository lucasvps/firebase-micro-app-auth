import 'package:get_it/get_it.dart';
import '../../external/i_auth_repository.dart';
import '../interfaces/i_change_password_usecase.dart';

class ChangePasswordUsecase implements IChangePasswordUsecase {
  @override
  Future call({required String newPassword}) {
    return GetIt.I
        .get<IAuthRepository>()
        .changePassword(newPassword: newPassword);
  }
}
