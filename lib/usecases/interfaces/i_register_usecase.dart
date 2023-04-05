import 'package:dartz/dartz.dart';

import '../../utils/errors/auth_custom_exception.dart';
import '../../utils/success/success_models.dart';

abstract class IRegisterUsecase {
  Future<Either<AuthCustomException, RegisterSuccess>> call({
    required String email,
    required String password,
  });
}
