import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:micro_app_auth/external/i_auth_repository.dart';
import 'package:micro_app_auth/usecases/implementations/usecases.dart';
import 'package:micro_app_auth/utils/errors/auth_custom_exception.dart';
import 'package:micro_app_auth/utils/success/success_models.dart';
import 'package:mocktail/mocktail.dart';

class AuthRepositoryMock extends Mock implements IAuthRepository {}

void main() {
  late final LoginUsecase loginUsecase;
  late final IAuthRepository authRepositoryMock;

  setUpAll(() async {
    GetIt.I.registerSingleton<IAuthRepository>(AuthRepositoryMock());

    authRepositoryMock = GetIt.I.get<IAuthRepository>();
    loginUsecase = LoginUsecase();
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("LoginUsecase", () {
    test("Should return a AuthCustomException if fails", () async {
      when(() => authRepositoryMock.loginWithEmailAndPassword(
          email: "email@email.com",
          password: '12345678')).thenThrow(Exception());

      final result = await loginUsecase.call(
          email: "email@email.com", password: '12345678');

      expect(
        // ignore: unnecessary_type_check
        result.leftMap((error) => error is AuthCustomException),
        const Left(true),
      );
    });

    test(
        "Should return the correct message to the usecase upon AuthCustomException",
        () async {
      when(() => authRepositoryMock.loginWithEmailAndPassword(
          email: "email@email.com", password: '12345678')).thenAnswer(
        (_) async => const Left(
          AuthCustomException(message: "Erro aqui!"),
        ),
      );

      final result = await loginUsecase.call(
          email: "email@email.com", password: '12345678');

      expect(
        result.leftMap((error) => error.message == "Erro aqui!"),
        const Left(true),
      );
    });

    test("Should return LoginSuccess when calling login usecase with success",
        () async {
      when(() => authRepositoryMock.loginWithEmailAndPassword(
          email: "email@email.com", password: '12345678')).thenAnswer(
        (_) async => Right(
          LoginSuccess(),
        ),
      );

      final result = await loginUsecase(
        email: "email@email.com",
        password: '12345678',
      );

      expect(
        result,
        Right(LoginSuccess()),
      );
    });
  });
}
