import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_app_auth/external/firebase_auth_datasource.dart';
import 'package:micro_app_auth/utils/errors/auth_custom_exception.dart';
import 'package:micro_app_auth/utils/success/success_models.dart';
import 'package:mocktail/mocktail.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late final FirebaseAuthDatasource firebaseAuthDatasource;
  late final FirebaseAuthMock firebaseAuthMock;

  String userNotFoundErrorMessage =
      "Não foi encontrado nenhum usuário com este email.";

  String wrongPasswordErrorMessage = "Senha incorreta.";

  String emailAlreadyInUseErrorMessage = "Este email já esta em uso.";

  setUpAll(() async {
    firebaseAuthMock = FirebaseAuthMock();
    firebaseAuthDatasource = FirebaseAuthDatasource(firebaseAuthMock);
    WidgetsFlutterBinding.ensureInitialized();
  });

  group("FirebaseAuthDatasource.Login", () {
    test(
        "Should return a AuthCustomException with correct error message on Login if user not found",
        () async {
      when(
        () => firebaseAuthMock.signInWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenAnswer((_) => throw FirebaseAuthException(code: 'user-not-found'));

      final result = await firebaseAuthDatasource.loginWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(
          result, Left(AuthCustomException(message: userNotFoundErrorMessage)));
      expect(
        result.leftMap((error) => error.message == userNotFoundErrorMessage),
        const Left(true),
      );
    });

    test(
        "Should return a AuthCustomException with correct error message on Login if wrong password is used",
        () async {
      when(
        () => firebaseAuthMock.signInWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenAnswer((_) => throw FirebaseAuthException(code: 'wrong-password'));

      final result = await firebaseAuthDatasource.loginWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(result,
          Left(AuthCustomException(message: wrongPasswordErrorMessage)));
      expect(
        result.leftMap((error) => error.message == wrongPasswordErrorMessage),
        const Left(true),
      );
    });

    test("Should return a LoginSuccess if the user sign in with success",
        () async {
      when(
        () => firebaseAuthMock.signInWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenAnswer(
        (invocation) async => MockUserCredential(),
      );

      final result = await firebaseAuthDatasource.loginWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(result, Right(LoginSuccess()));
    });
  });

  group("FirebaseAuthDatasource.Register", () {
    test(
        "Should return a AuthCustomException with correct error message on Register if email already in use",
        () async {
      when(
        () => firebaseAuthMock.createUserWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenAnswer(
          (_) => throw FirebaseAuthException(code: 'email-already-in-use'));

      final result = await firebaseAuthDatasource.registerWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(result,
          Left(AuthCustomException(message: emailAlreadyInUseErrorMessage)));
      expect(
        result
            .leftMap((error) => error.message == emailAlreadyInUseErrorMessage),
        const Left(true),
      );
    });

    test("Should return a AuthCustomException if Exception been throw",
        () async {
      when(
        () => firebaseAuthMock.createUserWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenThrow(Exception());

      final result = await firebaseAuthDatasource.registerWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(result, const Left(AuthCustomException()));
      expect(
        result
            .leftMap((error) => error.message == "Ocorreu um erro inesperado."),
        const Left(true),
      );
    });

    test("Should return a RegisterSuccess if the user sign up with success",
        () async {
      when(
        () => firebaseAuthMock.createUserWithEmailAndPassword(
          email: "email@email.com",
          password: "12345678",
        ),
      ).thenAnswer(
        (invocation) async => MockUserCredential(),
      );

      final result = await firebaseAuthDatasource.registerWithEmailAndPassword(
        email: 'email@email.com',
        password: '12345678',
      );

      expect(result, Right(RegisterSuccess()));
    });
  });

  group("FirebaseAuthDatasource.PasswordRecover", () {
    String notPossibleToChangePasswordErrorMessage =
        "Não é possível alterar a senha para este email.";

    String invalidEmailErrorMessage = "Email inválido.";

    String userNotFoundErrorMessage = "Este email não está cadastrado.";

    test(
        "Should return a AuthCustomException with correct error message on PasswordRecover if sign in method is not email",
        () async {
      when(
        () => firebaseAuthMock.fetchSignInMethodsForEmail('email@email.com'),
      ).thenAnswer((_) async => ['google']);

      when(
        () => firebaseAuthMock.fetchSignInMethodsForEmail('email@email.com'),
      ).thenAnswer((_) async => []);

      final result = await firebaseAuthDatasource.passwordRecover(
        email: 'email@email.com',
      );

      expect(
        result,
        Left(AuthCustomException(
            message: notPossibleToChangePasswordErrorMessage)),
      );
      expect(
        result.leftMap((error) =>
            error.message == notPossibleToChangePasswordErrorMessage),
        const Left(true),
      );
    });

    test(
        "Should return a AuthCustomException with correct error message on PasswordRecover if email is not valid",
        () async {
      when(
        () => firebaseAuthMock.fetchSignInMethodsForEmail(
          "email@email.com",
        ),
      ).thenAnswer((_) async => ['password']);

      when(
        () => firebaseAuthMock.sendPasswordResetEmail(
          email: "email@email.com",
        ),
      ).thenAnswer(
          (_) => throw FirebaseAuthException(code: 'auth/invalid-email'));

      final result = await firebaseAuthDatasource.passwordRecover(
        email: 'email@email.com',
      );

      expect(
          result, Left(AuthCustomException(message: invalidEmailErrorMessage)));
      expect(
        result.leftMap((error) => error.message == invalidEmailErrorMessage),
        const Left(true),
      );
    });

    test(
        "Should return a AuthCustomException with correct error message on PasswordRecover if user not found",
        () async {
      when(
        () => firebaseAuthMock.fetchSignInMethodsForEmail(
          "email@email.com",
        ),
      ).thenAnswer((_) async => ['password']);

      when(
        () => firebaseAuthMock.sendPasswordResetEmail(
          email: "email@email.com",
        ),
      ).thenAnswer(
          (_) => throw FirebaseAuthException(code: 'auth/user-not-found'));

      final result = await firebaseAuthDatasource.passwordRecover(
        email: 'email@email.com',
      );

      expect(
        result.leftMap((error) => error.message == userNotFoundErrorMessage),
        const Left(true),
      );
    });

    test(
        "Should return a RequestSuccess if the user could send passwordRecoverEmauil with success",
        () async {
      when(
        () => firebaseAuthMock.fetchSignInMethodsForEmail(
          "email@email.com",
        ),
      ).thenAnswer((_) async => ['password']);

      when(
        () => firebaseAuthMock.sendPasswordResetEmail(
          email: "email@email.com",
        ),
      ).thenAnswer((invocation) => Future.value());

      final result = await firebaseAuthDatasource.passwordRecover(
        email: 'email@email.com',
      );

      expect(result, Right(RequestSuccess()));
    });
  });

  group("FirebaseAuthDatasource.Logout", () {
    test(
        "Should return a AuthCustomException with correct error message on Logout if has Exception",
        () async {
      when(() => firebaseAuthMock.signOut()).thenAnswer(
        (invocation) => throw Exception(),
      );

      final result = await firebaseAuthDatasource.logout();

      expect(result, const Left(AuthCustomException()));
      expect(
        result
            .leftMap((error) => error.message == "Ocorreu um erro inesperado."),
        const Left(true),
      );
    }, skip: "Skipped");

    //

    test("Should return a RequestSuccess if the user sign out with success",
        () async {
      when(() => firebaseAuthMock.signOut()).thenAnswer(
        (invocation) => Future.value(),
      );

      final result = await firebaseAuthDatasource.logout();

      expect(result, Right(RequestSuccess()));
    }, skip: "Skipped");
  });
}
