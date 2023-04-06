import 'package:dartz/dartz.dart';
import '../../../utils/success/success_models.dart';
import '../../utils/errors/auth_custom_exception.dart';

abstract class ILoginWithAppleUsecase {
  Future<Either<AuthCustomException, LoginSuccess>> call();
}
