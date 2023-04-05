import 'package:dartz/dartz.dart';

import '../../utils/errors/auth_custom_exception.dart';
import '../../utils/success/success_models.dart';

abstract class IDeleteProfileUsecase {
  Future<Either<AuthCustomException, RequestSuccess>> call();
}
