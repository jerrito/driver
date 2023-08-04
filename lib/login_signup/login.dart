import 'dart:math';

import 'package:country_code_picker/country_code_picker.dart';
//import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:driver/constants/Size_of_screen.dart';
import 'package:driver/constants/strings.dart';
import 'package:driver/login_signup/otp.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:driver/widgets/MainInput.dart';
import 'package:driver/databases/firebase_services.dart';
import 'package:driver/main.dart';
import 'package:driver/userProvider.dart';
import 'package:provider/provider.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key}) : super(key: key);

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  List<String> pics = ["god_of war.png"];
  int passwordSee = 0;
  String countryCode = "+233";
  String countryShortCode = "Gh";
  var firebaseService = FirebaseServices();
  CustomerProvider? customerProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> formLogin = GlobalKey();
  bool loadingornot = false;
  // final TextEditingController number=TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController password = TextEditingController();
  String? pic;
  int index_2 = 0;
  bool obscure_2 = true;
  @override
  void initState() {
    customerProvider = context.read<CustomerProvider>();
    pic = (pics[Random().nextInt(pics.length)]).toString();
    Random().nextInt(pics.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     Color.fromRGBO(210, 230, 250, 0.2),
              //     Color.fromRGBO(210, 230, 250, 0.2)
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              color: Color.fromRGBO(210, 230, 250, 0.2)),
          padding: const EdgeInsets.all(10),
          child: Visibility(
            visible: !loadingornot,
            replacement: const Center(
              child: SpinKitChasingDots(
                color: Colors.pink,
                size: 50.0,
              ),
            ),
            child: Form(
              key: formLogin,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 30),
                        const Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: hS * 15,
                            backgroundImage: Image.asset("./assets/images/deliver.png",
                                    height: h / 3,
                                    width: w,
                                    fit: BoxFit.scaleDown)
                                .image,
                          ),
                        ),
                        const SizedBox(height: 15),
                        MainInput(
                          validator: phoneNumberValidator,
                          controller: number,
                          label: const Text("Number"),
                          //hintText: "0244444444",
                          keyboardType: TextInputType.number,
                          prefixIcon: selectCountry(),
                          obscureText: false,
                          // suffixIcon:Icon(Icons.person) ,
                        ),
                      ],
                    ),
                  ),
                  SecondaryButton(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    onPressed: loadingornot
                        ? null
                        : () async {
                            if (formLogin.currentState?.validate() == true) {
                              await loginWithPhoneNumber();
                            }
                          },
                    color: Colors.green,
                    text: "Login",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                        child: Row(
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          child: const Text("Signup"),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "signup");
                          },
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  String? phoneNumberValidator(String? value) {
    // final pattern = RegExp("([0][2358])[0-9]{8}");
    //
    // if (pattern.stringMatch(value ?? "") != value) {
    //   return AppStrings.invalidPhoneNumber;
    // }

    if (value?.isEmpty == true) {
      return AppStrings.isRequired;
    }
    return null;
  }

  String? pinValidator(String? value) {
    final pattern = RegExp("[0-9]{4}");
    if (value?.isEmpty == true) {
      return AppStrings.isRequired;
    } else if (pattern.stringMatch(value ?? "") != value) {
      return AppStrings.isNotEqual;
    }
    return null;
  }

  Future<void> loginWithPhoneNumber() async {
    //print("start");
    setState(() {
      loadingornot = true;
    });
    String completeNumber = "$countryCode${number.text}";
    var result = await customerProvider?.getUser(phoneNumber: completeNumber);
    // print("start_2");

    if (result?.status == QueryStatus.successful) {
      var user = result?.data;
      // print("this is ${user?.number}");
      if (user?.number == completeNumber) {
        await phoneSignIn(phoneNumber: completeNumber);

        // else{
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 5),
        //     content: Text("Password is invalid",style:TextStyle(color:Colors.white)),
        //     backgroundColor: Color.fromRGBO(20, 100, 150, 1),));
        //   setState(() {
        //     loadingornot = false;
        //   });
        // }

        return;
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Number is not registered",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(20, 100, 150, 1),
        ));
        setState(() {
          loadingornot = false;
        });
      }

      // setState(() {
      //   isLoading = false;
      // });

      // PrimarySnackBar(context).displaySnackBar(
      //   message: AppStrings.noAccountFoundErrorText,
      //   backgroundColor: AppColors.errorRed,
      // );

      return;
    } else if (result?.status == QueryStatus.failed) {
      if (!context.mounted) return;
      setState(() {
        loadingornot = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 5),
        content:
            Text("No account found", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(20, 100, 150, 1),
      ));
      //print("user?. none");
      // setState(() {
      //   isLoading = false;
      // });

      // PrimarySnackBar(context).displaySnackBar(
      //   message: (result?.error ?? "Error logging in").toString(),
      //   backgroundColor: AppColors.errorRed,
      // );
    }
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    //print("verification completed ${authCredential.smsCode}");
    // print(" ${authCredential.verificationId}");
    User? user = FirebaseAuth.instance.currentUser;

    if (authCredential.smsCode != null) {
      try {
        UserCredential credential =
            await user!.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await _auth.signInWithCredential(authCredential);
        }
      }
      // setState(() {
      //   isLoading = false;
      // });
      //Navigator.pushNamed(context, '/transfer');
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    //  print("verification failed ${exception.message}");
    if (exception.code == 'invalid-phone-number') {
      setState(() {
        loadingornot = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 5),
        content: Text("The phone number entered is invalid!",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(20, 100, 150, 1),
      ));
    }
    setState(() {
      loadingornot = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 5),
      content: Text("Coudn't verify user, try again",
          style: TextStyle(color: Colors.white)),
      backgroundColor: Color.fromRGBO(20, 100, 150, 1),
    ));
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    // setState(() {
    //   isLoading = false;
    // });
    //ask();
    // this.verificationId = verificationId;
    // print(forceResendingToken);
    // print(sms);
    //print(verificationId);
    // print("code sent");

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loadingornot = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerify(
            otpRequest: OTPRequest(
                forceResendingToken: forceResendingToken,
                verifyId: verificationId,
                phoneNumber: "$countryCode${number.text}",
                //name: username.text,
                see: "register",
                onSuccessCallback: () async {
                  if (!context.mounted) return;
                  customerProvider=context.read<CustomerProvider>();
                  var result_2 = await customerProvider?.getUser(
                      phoneNumber: "$countryCode${number.text}");
                  if (result_2?.status == QueryStatus.successful) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 5),
                      content: Text(
                          "Successfully logged in ${result_2?.data?.fullName}",
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: const Color.fromRGBO(20, 100, 150, 1),
                    ));
                    Navigator.pushNamed(context, 'home');
                  }
                  // Future.delayed(Duration(seconds:120),(){
                  //   Navigator.pushNamed(context, 'login');
                  // });
                }),
          ),
        ),
      );
    });
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  Widget selectCountry() {
    return CountryCodePicker(
        textStyle: const TextStyle(color: Colors.black),
        // onInit: (val) {
        //   // print(val);
        //   countryCode = val.toString();
        //   countryShortCode = val!.code!;
        //   // print(countryCode);
        // },
        initialSelection: countryShortCode,
        favorite: const [
          "GH",
          "USA",
        ],
        onChanged: (val) {
          // print(val);
          countryCode = val.toString();
          countryShortCode = val.code!;
          // print(countryCode);
        });
  }
}
