abstract class IOnboardingUsecase {
  Future call({
    required String name,
    required String email,
    String? gender,
    String? bornDate,
    String? weight,
    String? height,
  });
}
