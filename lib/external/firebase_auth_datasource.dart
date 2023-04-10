import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/authentication.dart';
import '../utils/errors/auth_custom_exception.dart';
import '../utils/success/success_models.dart';
import 'i_auth_repository.dart';

class FirebaseAuthDatasource implements IAuthRepository {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuthInstace;

  FirebaseAuthDatasource(this.firebaseAuthInstace);

  @override
  Future<Either<AuthCustomException, LoginSuccess>> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await firebaseAuthInstace.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Authentication.saveToken(
        await firebaseAuthInstace.currentUser?.getIdToken() ?? "",
      );

      return Right(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const Left(
          AuthCustomException(
            message: "Não foi encontrado nenhum usuário com este email.",
          ),
        );
      } else if (e.code == 'wrong-password') {
        return const Left(AuthCustomException(
          message: "Senha incorreta.",
        ));
      } else {
        return const Left(AuthCustomException());
      }
    } catch (e) {
      return const Left(AuthCustomException());
    }
  }

  @override
  Future<Either<AuthCustomException, LoginSuccess>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await firebaseAuthInstace.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);

        final User? currentUser = firebaseAuthInstace.currentUser;
        assert(user.uid == currentUser!.uid);

        Authentication.saveToken(
          await FirebaseAuth.instance.currentUser!.getIdToken(),
        );

        return Right(LoginSuccess());
      } else {
        debugPrint("user == null");
        return const Left(AuthCustomException());
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'user-not-found') {
        return const Left(
          AuthCustomException(
            message: "Não foi encontrado nenhum usuário com este email.",
          ),
        );
      } else if (e.code == 'wrong-password') {
        return const Left(AuthCustomException(
          message: "Senha incorreta.",
        ));
      } else {
        return const Left(AuthCustomException());
      }
    } catch (e) {
      debugPrint(e.toString());
      return const Left(AuthCustomException());
    }
  }

  @override
  Future<Either<AuthCustomException, LoginSuccess>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fixDisplayNameFromApple = [
        credential.givenName ?? "",
        credential.familyName ?? "",
      ].join(' ').trim();

      final AuthCredential firebaseCredentials =
          OAuthProvider('apple.com').credential(
        accessToken: credential.authorizationCode,
        idToken: credential.identityToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(firebaseCredentials);

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(fixDisplayNameFromApple);

      FirebaseAuth.instance.currentUser?.reload();

      Authentication.saveToken(
        await FirebaseAuth.instance.currentUser!.getIdToken(),
      );

      final User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);

        final User? currentUser = firebaseAuthInstace.currentUser;
        assert(user.uid == currentUser!.uid);

        Authentication.saveToken(
          await FirebaseAuth.instance.currentUser!.getIdToken(),
        );

        return Right(LoginSuccess());
      } else {
        return const Left(AuthCustomException());
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'user-not-found') {
        return const Left(
          AuthCustomException(
            message: "Não foi encontrado nenhum usuário com este email.",
          ),
        );
      } else if (e.code == 'wrong-password') {
        return const Left(AuthCustomException(
          message: "Senha incorreta.",
        ));
      } else {
        return const Left(AuthCustomException());
      }
    } catch (e) {
      log(e.toString());
      return const Left(AuthCustomException());
    }
  }

  @override
  Future<Either<AuthCustomException, RequestSuccess>> logout() async {
    try {
      await firebaseAuthInstace.signOut();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      return Right(RequestSuccess());
    } catch (e) {
      return const Left(AuthCustomException());
    }
  }

  @override
  Future<Either<AuthCustomException, RegisterSuccess>>
      registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuthInstace.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Authentication.saveToken(
        await firebaseAuthInstace.currentUser?.getIdToken() ?? "",
      );

      return Right(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'email-already-in-use') {
        return const Left(
          AuthCustomException(
            message: "Este email já esta em uso.",
          ),
        );
      } else {
        return const Left(
          AuthCustomException(),
        );
      }
    } catch (e) {
      log(e.toString());
      return const Left(
        AuthCustomException(),
      );
    }
  }

  @override
  Future<Either<AuthCustomException, RequestSuccess>> changePassword(
      {required String newPassword}) async {
    try {
      var user = firebaseAuthInstace.currentUser!;

      await user.updatePassword(newPassword);
      return Right(RequestSuccess());
    } catch (e) {
      log(e.toString());
      return const Left(AuthCustomException(
        message: "Erro ao redefinir a senha.",
      ));
    }
  }

  @override
  Future<Either<AuthCustomException, RequestSuccess>> passwordRecover({
    required String email,
  }) async {
    List<String> loginMethods =
        await firebaseAuthInstace.fetchSignInMethodsForEmail(email);

    if (loginMethods.isNotEmpty) {
      if (loginMethods.contains("password")) {
        try {
          await firebaseAuthInstace.sendPasswordResetEmail(email: email);

          return Right(RequestSuccess());
        } on FirebaseAuthException catch (e) {
          log(e.toString());
          log(e.toString());
          if (e.code == 'auth/invalid-email' || e.code == 'invalid-email') {
            return const Left(
              AuthCustomException(
                message: "Email inválido.",
              ),
            );
          } else if (e.code == 'auth/user-not-found' ||
              e.code == 'user-not-found') {
            return const Left(
              AuthCustomException(
                message: "Este email não está cadastrado.",
              ),
            );
          } else {
            return const Left(
              AuthCustomException(),
            );
          }
        } catch (e) {
          log(e.toString());
          return const Left(
            AuthCustomException(),
          );
        }
      } else {
        return const Left(
          AuthCustomException(
            message: "Não é possível alterar a senha para este email.",
          ),
        );
      }
    } else {
      return const Left(
        AuthCustomException(
          message: "Não é possível alterar a senha para este email.",
        ),
      );
    }
  }

  @override
  Future<Either<AuthCustomException, RequestSuccess>> deleteAccount() async {
    if (firebaseAuthInstace.currentUser == null) {
      return const Left(
        AuthCustomException(),
      );
    } else {
      try {
        await firebaseAuthInstace.currentUser?.delete();

        return Right(RequestSuccess());
      } on FirebaseAuthException catch (e) {
        log(e.toString());
        if (e.code == 'firebasefirebaseAuthInstace/requires-recent-login' ||
            e.code == 'requires-recent-login' ||
            e.code == 'auth/requires-recent-login') {
          return const Left(
            AuthCustomException(
              message:
                  "É necessário que você esteja recentemente logado para deletar sua conta. Por favor saia e faça login novamente para realizar a ação.",
            ),
          );
        }
        return const Left(
          AuthCustomException(),
        );
      } catch (e) {
        log(e.toString());
        return const Left(
          AuthCustomException(),
        );
      }
    }
  }
}
