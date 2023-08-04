import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:driver/constants/Size_of_screen.dart';
import 'package:driver/constants/strings.dart';
import 'package:driver/login_signup/otp.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:driver/widgets/MainInput.dart';
import 'package:driver/databases/firebase_services.dart';
import 'package:driver/main.dart';
import 'package:driver/models/user.dart' as User_main;
import 'package:driver/userProvider.dart';
import 'package:provider/provider.dart';

// showExceptionAlertDialog(
// context,
// exception: e,
// title: 'Sign In Failed',
// );

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  GlobalKey<ScaffoldMessengerState> scaffoldMessenger = GlobalKey();
  GlobalKey<FormState> form = GlobalKey();
  var firebaseService = FirebaseServices();
  CustomerProvider? userProvider;
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool checkLoading = true;
  bool loadingOrNot = false;
  int index_2 = 0;
  bool obscure_2 = true;
  String countryCode = "+233";
  String countryShortCode = "Gh";
  List<String> pics = [
    "god_of war.png",
  ];
  String? pic;
  @override
  void initState() {
    pic = (pics[Random().nextInt(pics.length)]).toString();

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
              visible: !loadingOrNot,
              replacement: const Center(
                  child: SpinKitFadingCube(
                color: Colors.pink,
                size: 50.0,
              )),
              child: Form(
                key: form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          const SizedBox(height: 30),
                          const Center(
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: hS * 15,
                              backgroundImage: Image.asset(
                                "./assets/images/deliver.png",
                                height: h / 3,
                                width: w,
                              ).image,
                            ),
                          ),
                          //Center(child: Text("Let's get things going by signing up", style: TextStyle(fontSize: 17, color: Colors.black),)),
                          const SizedBox(height: 15),
                          MainInput(
                            validator: fullNameValidator,
                            controller: fullName,
                            label: const Text("Full Name"),
                            prefixIcon: const Icon(Icons.person),
                            obscureText: false,
                            // suffixIcon:Icon(Icons.person) ,
                          ),
                          const SizedBox(height: 15),
                          MainInput(
                            validator: phoneNumberValidator,
                            controller: phoneNumber,
                            label: const Text("Phone Number"),
                            prefixIcon: selectCountry(),
                            keyboardType: TextInputType.number,
                            //  suffixIcon:Icon(Icons.remove_red_eye),
                            obscureText: false,
                          ),
                          const SizedBox(height: 15),
                          MainInput(
                            validator: emailValidator,
                            controller: email,
                            label: const Text("Email"),
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                            obscureText: false,
                            // suffixIcon:Icon(Icons.person) ,
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          MainInput(
                            validator: pinValidator,
                            controller: password,
                            label: const Text("Password"),
                            prefixIcon: const Icon(Icons.password_outlined),
                            suffixIcon: IconButton(
                                icon: obscure_2 == true
                                    ? SvgPicture.asset("./assets/svgs/eye.svg",
                                        color: Colors.green)
                                    : SvgPicture.asset(
                                        "./assets/svgs/eye-off.svg",
                                        color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    obscure_2 = false;
                                    index_2++;
                                    if (index_2 % 2 == 0) {
                                      obscure_2 = true;
                                    }
                                  });
                                }),
                            obscureText: obscure_2,
                          ),
                        ],
                      ),
                    ),
                    SecondaryButton(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      onPressed: loadingOrNot
                          ? null
                          : () async {
                              if (form.currentState?.validate() == true) {
                                setState(() {
                                  loadingOrNot = true;
                                });
                                await pashewFoodRegister();

                                // Navigator.pushNamed(context,"homepage");
                              }
                            },
                      color: Colors.green,
                      text: 'Signup',
                    ),
                    Center(
                        child: Row(
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          child: const Text("Signin"),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "login");
                          },
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            )));
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

  String? phoneNumberValidator(String? value) {
    final pattern = RegExp("([0][2358])[0-9]{8}");

    // if (pattern.stringMatch(value ?? "") != value) {
    //   return AppStrings.invalidPhoneNumber;
    // }
    if (value?.isEmpty == true) {
      return AppStrings.isRequired;
    }
    return null;
  }

  String? fullNameValidator(String? value) {
    final pattern = RegExp("([A-Z][a-z]+)[/s/ ]+([A-Z][a-z]+)");

    if (pattern.stringMatch(value ?? "") != value) {
      return AppStrings.invalidFullName;
    }

    return null;
  }

  String? nameValidator(String? value) {
    final pattern = RegExp("[A-Z]([a-z]+)");

    if (pattern.stringMatch(value ?? "") != value) {
      return AppStrings.invalidName;
    }

    return null;
  }

  String? emailValidator(String? value) {
    final pattern =
        RegExp("^([a-zA-Z0-9_/-/./]+)@([a-zA-Z0-9_/-/.]+)[.]([a-zA-Z]{2,5})");
    if (pattern.stringMatch(value ?? "") != value) {
      return AppStrings.invalidEmails;
    }
    return null;
  }

  Future<void> pashewFoodRegister() async {
    //  print("sup");
    String completePhoneNumber = "$countryCode${phoneNumber.text}";
    var resultMain =
        await FirebaseServices().getUser(phoneNumber: completePhoneNumber);

    //  print(resultMain?.status);
    if (resultMain?.status == QueryStatus.successful) {
      var userOld = resultMain?.data;
      if (userOld?.number == completePhoneNumber) {
        setState(() {
          loadingOrNot = false;
        });
        //  print("Account already exist");
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Account already exist",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(20, 100, 150, 1),
        ));

        // PrimarySnackBar(context).displaySnackBar(
        //   message: AppStrings.accountExistErrorMessage,
        //   backgroundColor: AppColors.errorRed,
        // );

        return;
      }
      phoneSignIn(phoneNumber: "$countryCode${phoneNumber.text}");
    }
    setState(() {
      loadingOrNot = false;
    });
    // print("Account error");
    // ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(duration: Duration(seconds: 5),
    //       content: Text("Error registering account",style:TextStyle(color:Colors.white)),
    //       backgroundColor: Color.fromRGBO(20, 100, 150, 1),));
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 120),
      phoneNumber: phoneNumber,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    // print("verification completed ${authCredential.smsCode}");
    // print(" ${authCredential.verificationId}");
    User? user = FirebaseAuth.instance.currentUser;

    if (authCredential.smsCode != null) {
      try {
        UserCredential credential =
            await user!.linkWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await auth.signInWithCredential(authCredential);
        }
      }
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    // print("verification failed ${exception.message}");
    if (exception.code == 'invalid-phone-number') {}
    setState(() {
      loadingOrNot = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 5),
      content: Text("Verification failed. Please try again",
          style: TextStyle(color: Colors.white)),
      backgroundColor: Color.fromRGBO(20, 100, 150, 1),
    ));
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    //print(verificationId);
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerify(
            otpRequest: OTPRequest(
                forceResendingToken: forceResendingToken,
                verifyId: verificationId,
                phoneNumber: "$countryCode${phoneNumber.text}",
                //name: username.text,
                see: "register",
                onSuccessCallback: () async {
                  var user = User_main.Customer(
                      // id: auth.currentUser?.uid,
                      number: "$countryCode${phoneNumber.text}",
                      fullName: fullName.text,
                      email: email.text,
                      password: password.text,
                      location: "",
                      latitude: 0,
                      longitude: 5,
                      image: "");
                  var result = await FirebaseServices().saveUser(user: user);
                  if (result?.status == QueryStatus.successful) {
                    finalRegister();
                    // await uploadingData(name.text, number.text, airtime.toString(),
                    // data.toString(), sms.toString(), pin1.text);

                  }
                }),
          ),
        ),
      );
    });
  }

  void finalRegister() async {
    userProvider = context.read<CustomerProvider>();
    // print("Account success");
    var result2 = await userProvider?.getUser(
        phoneNumber: "$countryCode${phoneNumber.text}");
    if(!context.mounted)return;
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      duration: const Duration(seconds: 5),
      content: Text("Successfully registered ${userProvider?.appUser?.fullName}",
          style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromRGBO(20, 100, 150, 1),
    ));

    // print(result2?.status);
    if (result2?.status == QueryStatus.successful) {
      navigate();
    }
  }

  navigate() {
    return Navigator.pushNamed(context, 'home');
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  Widget selectCountry() {
    return CountryCodePicker(
        // onInit: (val) {
        //   // print(val);
        //   countryCode = val.toString();
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
          //  print(countryCode);
        });
  }
}
