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
  late final RegisterUsecase registerUsecase;
  late final IAuthRepository authRepositoryMock;

  setUpAll(() async {
    GetIt.I.registerSingleton<IAuthRepository>(AuthRepositoryMock());

    authRepositoryMock = GetIt.I.get<IAuthRepository>();
    registerUsecase = RegisterUsecase();
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("registerUsecase", () {
    test("Should return a AuthCustomException if fails", () async {
      when(() => authRepositoryMock.registerWithEmailAndPassword(
          email: "email@email.com", password: '12345678')).thenAnswer(
        (_) async => const Left(AuthCustomException()),
      );

      final result = await registerUsecase.call(
        email: "email@email.com",
        password: '12345678',
      );

      expect(result, isA<Left<AuthCustomException, dynamic>>());
    });

    test(
        "Should return the correct message to the usecase upon AuthCustomException",
        () async {
      when(() => authRepositoryMock.registerWithEmailAndPassword(
          email: "email@email.com", password: '12345678')).thenAnswer(
        (_) async => const Left(
          AuthCustomException(message: "Erro aqui!"),
        ),
      );

      final result = await registerUsecase.call(
        email: "email@email.com",
        password: '12345678',
      );

      expect(
        result.leftMap((error) => error.message == "Erro aqui!"),
        const Left(true),
      );
    });

    test(
        "Should return RegisterSuccess when calling login usecase with success",
        () async {
      when(() => authRepositoryMock.registerWithEmailAndPassword(
          email: "email@email.com", password: '12345678')).thenAnswer(
        (_) async => Right(
          RegisterSuccess(),
        ),
      );

      final result = await registerUsecase(
        email: "email@email.com",
        password: '12345678',
      );

      expect(
        result,
        Right(RegisterSuccess()),
      );
    });
  });
}
