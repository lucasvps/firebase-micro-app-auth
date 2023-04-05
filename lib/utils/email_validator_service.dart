import 'package:email_validator/email_validator.dart';

abstract class IEmailValidatorService {
  bool validate(String email);
}

class EmailValidatorService implements IEmailValidatorService {
  @override
  bool validate(String email) {
    return EmailValidator.validate(email);
  }
}
