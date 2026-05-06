import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import '../controller/login_controller.dart';
import '../core/constant/app_color.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../core/constant/app_string.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.06),
              AppColor.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            return Stack(
              children: [
                /// ─── Main Content ──────────────────────────────
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      /// ─── Header ─────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primary.withValues(alpha: 0.08),
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            size: 48,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          "Welcome to ${AppString.appName}",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Enter your phone number to continue",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: 48),

                      /// ─── Phone Input ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            IntlPhoneField(
                              cursorColor: AppColor.primary,
                              controller: controller.phoneController,
                              decoration: InputDecoration(
                                hintText: 'Enter your number',
                                filled: true,
                                fillColor: AppColor.inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              initialCountryCode: 'PK',
                              dropdownIcon: const Icon(Icons.arrow_drop_down, color: AppColor.primary),
                              dropdownTextStyle: const TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              pickerDialogStyle: PickerDialogStyle(
                                backgroundColor: Colors.white,
                                countryCodeStyle: const TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                countryNameStyle: const TextStyle(color: Colors.black87),
                                searchFieldInputDecoration: InputDecoration(
                                  hintText: "Search country",
                                  prefixIcon: const Icon(Icons.search, color: AppColor.primary),
                                  filled: true,
                                  fillColor: AppColor.inputFill,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColor.primary),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              onChanged: (phone) {
                                controller.phoneNumber.value = phone.completeNumber;
                                controller.isFormValid.value = controller.validatePhone(phone.number);
                              },
                            ),

                            const SizedBox(height: 16),

                            /// ─── Send Code Button ─────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: Obx(() => ElevatedButton(
                                onPressed: controller.isFormValid.value
                                    ? () => controller.sendOtp()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.isFormValid.value
                                      ? AppColor.primary
                                      : AppColor.inputFill,
                                  foregroundColor: controller.isFormValid.value
                                      ? AppColor.white
                                      : AppColor.blueGrey,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Send Verification Code",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ─── OTP Input (animated) ───────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: controller.isOtpSent.value
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColor.cardBg,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Verification Code",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Enter the 6-digit code sent to your phone",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      cursorColor: AppColor.primary,
                                      maxLength: 6,
                                      controller: controller.otpController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 8,
                                        color: AppColor.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        filled: true,
                                        fillColor: AppColor.inputFill,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: AppColor.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      onChanged: (value) {
                                        controller.otp.value = value;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    /// ─── Login Button ─────────────
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: Obx(() => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: controller.otp.value.length == 6
                                              ? const LinearGradient(
                                                  colors: [AppColor.primary, AppColor.second],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                )
                                              : null,
                                          color: controller.otp.value.length == 6
                                              ? null
                                              : AppColor.inputFill,
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: controller.otp.value.length == 6
                                              ? () => controller.verifyOtp()
                                              : null,
                                          child: Text(
                                            "Verify & Login",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: controller.otp.value.length == 6
                                                  ? AppColor.white
                                                  : AppColor.blueGrey,
                                            ),
                                          ),
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 32),

                      /// ─── Legal Text ─────────────────────────
                      Center(
                        child: Text(
                          "By tapping 'Verify & Login', you accept our\nTerms of Service and Privacy Policy.",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                /// ─── Loading Overlay ────────────────────────────
                if (controller.isLoading.value)
                  Container(
                    color: Colors.white.withValues(alpha: 0.85),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColor.primary, strokeWidth: 3),
                          SizedBox(height: 16),
                          Text(
                            "Please wait...",
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
