import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:micro_app_auth/external/i_auth_repository.dart';
import 'package:micro_app_auth/usecases/implementations/usecases.dart';
import 'package:micro_app_auth/utils/email_validator_service.dart';
import 'package:micro_app_auth/utils/errors/auth_custom_exception.dart';
import 'package:micro_app_auth/utils/success/success_models.dart';
import 'package:mocktail/mocktail.dart';

class EmailValidatorMock extends Mock implements IEmailValidatorService {}

class AuthRepositoryMock extends Mock implements IAuthRepository {}

void main() {
  late final RecoverPasswordUsecase recoverPasswordUsecase;
  late final IAuthRepository authRepositoryMock;
  late final EmailValidatorMock emailValidatorMock;

  setUpAll(() {
    GetIt.I.registerSingleton<IAuthRepository>(AuthRepositoryMock());
    authRepositoryMock = GetIt.I.get<IAuthRepository>();
    emailValidatorMock = EmailValidatorMock();
    recoverPasswordUsecase = RecoverPasswordUsecase();
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("RecoverPasswordUsecase", () {
    test(
        "Should return a AuthCustomException with correct message if the email is not valid",
        () async {
      when(() => emailValidatorMock.validate(any())).thenAnswer((_) => false);

      final result = await recoverPasswordUsecase(email: "email@email");

      expect(
        // ignore: unnecessary_type_check
        result.leftMap((failure) => failure is AuthCustomException),
        const Left(true),
      );
      expect(
        result.leftMap((error) => error.message == 'Este email é inválido'),
        const Left(true),
      );
    });

    test("Should call the repository method if the email is valid", () async {
      when(() => emailValidatorMock.validate(any())).thenAnswer((_) => true);

      when(() => authRepositoryMock.passwordRecover(email: "email@email.com"))
          .thenAnswer((_) async => Right(RequestSuccess()));

      await recoverPasswordUsecase(email: "email@email.com");

      verify(() => authRepositoryMock.passwordRecover(email: "email@email.com"))
          .called(1);
    });

    test("Should return a RequestSuccess when calling it with a valid email",
        () async {
      when(() => emailValidatorMock.validate(any())).thenAnswer((_) => true);

      when(() => authRepositoryMock.passwordRecover(email: "email@email.com"))
          .thenAnswer((_) async => Right(RequestSuccess()));

      final result = await recoverPasswordUsecase(email: "email@email.com");

      expect(
        result,
        Right(RequestSuccess()),
      );
    });
  });
}
