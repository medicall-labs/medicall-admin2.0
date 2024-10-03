import 'package:flutter/material.dart';
import 'package:admin_medicall/Providers/auth_provider.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Forms/form_input_with%20_label.dart';
import 'package:admin_medicall/Utils/Identity/identity.dart';
import 'package:admin_medicall/Utils/Widgets/button.dart';
import 'package:admin_medicall/Utils/Widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final bool? loggedout;
  LoginPage({super.key, this.loggedout});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool obscureText = false;

  bool isOtpRequested = false;
  bool validateMobileNumber = false;
  List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpaces.verticalSpace40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: FittedBox(
                        child: Text(
                          'Login to Continue...',
                          style: AppTextStyles.header,
                        ),
                      ),
                    ),
                    CustomTextWidget(),
                  ],
                ),
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Image.asset(
                      "assets/images/Logo.png",
                      width: 150,
                    ),
                  ),
                ),
                LabelledFormInput(
                    keyboardType: "number",
                    controller: _userIdController,
                    obscureText: false,
                    label: "Mobile Number"),
                if (_userIdController.text.length != 10 && validateMobileNumber)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      'Please enter your mobile number and request OTP',
                      style: AppTextStyles.validation,
                    ),
                  ),
                AppSpaces.verticalSpace10,
                Visibility(
                  visible: !isOtpRequested,
                  child: LabelledFormInput(
                      keyboardType: "Password",
                      controller: _passController,
                      obscureText: true,
                      label: "Password"),
                ),
                Visibility(
                    visible:
                    isOtpRequested && (_userIdController.text.length == 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Enter the 6 digit OTP",
                            style: AppTextStyles.label),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                                (index) => SizedBox(
                              width: 40,
                              child: TextFormField(
                                controller: _otpControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                decoration: InputDecoration(
                                  counterText: "",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: AppColor.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: AppColor.primary),
                                  ),
                                ),
                                onChanged: (value) {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          if (_userIdController.text.length != 10)
                            validateMobileNumber = !validateMobileNumber;
                          if (_userIdController.text.length == 10)
                            isOtpRequested = !isOtpRequested;
                        });

                        try {
                          if (isOtpRequested &&
                              _userIdController.text.length == 10) {
                            var otpResult = await AuthenticationProvider()
                                .otp(_userIdController.text);
                            if (_userIdController.text.isNotEmpty)
                              showMessage(
                                  backgroundColor: Colors.green,
                                  mainMessage: otpResult["message"],
                                  secondaryMessage:
                                  'Valid upto : ${otpResult["otp_expired_at_formatted"]}',
                                  context: context);
                          }
                        } catch (e) {}
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: FittedBox(
                          child: Text(
                            isOtpRequested &&
                                _userIdController.text.length == 10
                                ? "Sign in using Password"
                                : "Sign in using Whatsapp OTP",
                            style: AppTextStyles.label,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpaces.verticalSpace10,
                Consumer<AuthenticationProvider>(
                    builder: (context, auth, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (auth.resMessage != '') {
                          showMessage(
                              backgroundColor:
                              auth.resMessage == "Login successfull!"
                                  ? Colors.green
                                  : Colors.red,
                              secondaryMessage: auth.resMessage,
                              context: context);

                          ///Clear the response message to avoid duplicate
                          auth.clear();
                        }
                      });
                      return customButton(
                        text: 'Sign in',
                        buttonHeight: 50,
                        backgroundColor: AppColor.secondary,
                        tap: () {
                          if (isOtpRequested) {
                            _passController.text = _otpControllers
                                .map((controller) => controller.text)
                                .join('');
                          }
                          if (_userIdController.text.isEmpty ||
                              _passController.text.isEmpty) {
                            showMessage(
                                mainMessage: 'Sorry',
                                secondaryMessage: "All fields are required",
                                backgroundColor: Colors.red,
                                context: context);
                          } else {
                            auth.loginUser(
                              context: context,
                              mobileNumber: _userIdController.text.trim(),
                              password: _passController.text.trim(),
                              otp: isOtpRequested,
                            );
                          }
                        },
                        context: context,
                        status: auth.isLoading,
                      );
                    }),
                AppSpaces.verticalSpace40,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
