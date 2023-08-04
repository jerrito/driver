import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:driver/main.dart";
import "package:driver/models/user.dart";
import "package:driver/pages/display.dart";
import "package:driver/userProvider.dart";
import "package:driver/widgets/profile_container.dart";
import "package:provider/provider.dart";

import "../databases/firebase_services.dart";
import "../widgets/MainButton.dart";

class ProfileUpdate {
  final String imagePath;
  String? check;

  ProfileUpdate({required this.imagePath, this.check});
}
class Profile extends StatefulWidget {
  ProfileUpdate profileUpdate;

  Profile({super.key, required this.profileUpdate});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  CustomerProvider? customerProvider;
  GlobalKey<FormState> nameKey = GlobalKey();
  GlobalKey<FormState> emailKey = GlobalKey();
  GlobalKey<FormState> numberKey = GlobalKey();
  GlobalKey<FormState> locationKey = GlobalKey();
  GlobalKey<FormState> pinKey = GlobalKey();
  GlobalKey<FormState> medicalInfoKey = GlobalKey();
  File? _image;
  bool saveLoading=false;
  void changeProfilePic({required Customer? user}) async {
    String? img = user?.image;
    if (widget.profileUpdate.check == "see") {
      // print("he");
    } else if (widget.profileUpdate.check == "update") {
      img = widget.profileUpdate.imagePath;
      user?.image = img;
      // print("hell");

      await updateUser(user: user!);

      await Navigator.pushReplacementNamed(context, "profile");
    }
  }
  @override
  void initState() {
    super.initState();

    customerProvider = context.read<CustomerProvider>();
    changeProfilePic(user: customerProvider?.appUser);
    customerProvider = context.read<CustomerProvider>();
    // print(customerProvider?.appUser?.fullName);
    // print(customerProvider?.appUser?.image);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Container(
            color: const Color.fromRGBO(245, 245, 245, 0.6),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height* 0.25,
                  child: Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.green,
                          backgroundImage:customerProvider?.appUser?.image==""?
                          Image.asset("./assets/images/user.png",
                            fit: BoxFit.contain,).image:
                          Image.network("${customerProvider?.appUser?.image}",
                              errorBuilder:(BuildContext context,object,stackTrace){
                                return Container();
                              }
                          ).image,
                        ),
                      ),
                      Align(
                        alignment:Alignment.bottomCenter,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: () async {
                                await chooseProfileOptions();
                              }),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: [
                      const SizedBox(height: 50),
                      ProfileContainer(
                        title: '${customerProvider?.appUser?.fullName}',
                        onPressed: () {
                          showName(user: customerProvider?.appUser);

                        },
                      ),
                      ProfileContainer(
                        title: '${customerProvider?.appUser?.email}',
                        onPressed: () {
                          showEmail(user: customerProvider?.appUser);
                        },
                      ),
                      ProfileContainer(
                        title: '${customerProvider?.appUser?.number}',
                        onPressed: () {
                          showNumber(user: customerProvider?.appUser);
                        },
                      ),
                      ProfileContainer(
                        title: '${customerProvider?.appUser?.location?.substring(0,35)}...',
                        onPressed: () {},
                      ),
                      ProfileContainer(
                        title: 'Kumasi',
                        onPressed: () {},
                      ),
                      ProfileContainer(
                        title: 'exit',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "login");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
  String? phoneNumberValidator(String? value) {
    final pattern = RegExp("([0][2358])[0-9]{8}");

    if (pattern.stringMatch(value ?? "") != value) {
      return "Invalid PhoneNumber";
    }

    return null;
  }

  String? FullNameValidator(String? value) {
    final pattern = RegExp("([A-Z][a-z]+)[/s/ ]([A-Z][a-z]+)");

    if (pattern.stringMatch(value ?? "") != value) {
      return "Invalid fullname";
    }

    return null;
  }
  Future<void> showName({required Customer? user}) async {
    String? fullName = user?.fullName;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return saveLoading
                ? DialogLoading()
                : DialogProfile(
              profileType: "name",
              keys: nameKey,
              validator: FullNameValidator,
              onChanged: (value) {
                fullName = value;
              },
              initialValue: '${customerProvider?.appUser?.fullName}',
              onPressed: saveLoading
                  ? null
                  : () async {
                if (nameKey.currentState?.validate() == true) {
                  setState(() {
                    saveLoading = true;
                  });

                  user?.fullName = fullName;
                  await updateUser(user: user!);
                  setState(() {
                    saveLoading = false;
                    Navigator.pushReplacementNamed(
                        context, "profile");
                  });
                }
              },
            );
          });
        });
  }
  Future<void> showNumber({required Customer? user}) async {
    String? number = user?.number;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return saveLoading
                ?const  DialogLoading()
                : DialogProfile(
              keys: numberKey,
              profileType: "number",
              onChanged: (value) {
                number = value;
              },
              validator: phoneNumberValidator,
              initialValue: '0${user?.number?.substring(4)}',
              onPressed: saveLoading
                  ? null
                  : () async {
                if (numberKey.currentState?.validate() == true) {
                  setState(() {
                    saveLoading = true;
                  });

                  user?.number = '+233${number?.substring(1)}';
                  await updateUser(user: user!);
                  setState(() {
                    saveLoading = false;
                    Navigator.pushReplacementNamed(
                        context, "profile");
                  });
                }
              },
            );
          });
        });
  }

  Future<void> showEmail({required Customer? user}) async {
    String? email = user?.email;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return saveLoading
                ? const DialogLoading()
                : DialogProfile(
              keys: emailKey,
              validator: emailValidator,
              profileType: "email",
              onChanged: (value) {
                email = value;
              },
              initialValue: '${customerProvider?.appUser?.email}',
              onPressed: saveLoading
                  ? null
                  : () async {
                if (emailKey.currentState?.validate() == true) {
                  setState(() {
                    saveLoading = true;
                  });

                  user?.email = email;
                  await updateUser(user: user!);
                  setState(() {
                    saveLoading = false;
                    Navigator.pushReplacementNamed(
                        context, "profile");
                  });
                }
              },
            );
          });
        });
  }
  updateUser({required Customer user}) async {
    var result = await customerProvider?.updateUser(customer: user);
    if (result?.status == QueryStatus.successful) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 5),
        content: Text("Profile updated successfully",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(20, 100, 150, 1),
      ));

      return;
    }
    if (result?.status == QueryStatus.failed) {
      setState(() {
        saveLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 5),
        content:
        Text("Error saving details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(20, 100, 150, 1),
      ));
    }
  }
  Future<void> chooseProfileOptions() async {
    // String? number = user?.email;
    showModalBottomSheet<dynamic>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: Column(children: [
                  const Text("Choose from camera or gallery",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const  SizedBox(height: 50),
                  SecondaryButton(
                      text:"Camera",
                      onPressed: () async {
                        await getCameraImage();
                      },
                      color: Colors.pink,
                      backgroundColor: Colors.pink),
                  SizedBox(height: 20),
                  SecondaryButton(
                      text: "Gallery",
                      onPressed: () async {
                        await getFileImage();
                      },
                      backgroundColor: Colors.greenAccent,
                      color: Colors.greenAccent)
                ]));
          });
        });
  }

  String? inputValidator(String? value) {
    if (value?.isEmpty == true) {
      return "This field is required";
    }
    return null;
  }

  String? emailValidator(String? value) {
    final pattern =
    RegExp("^([a-zA-Z0-9_/-/./]+)@([a-zA-Z0-9_/-/.]+)[.]([a-zA-Z]{2,5})");
    if (pattern.stringMatch(value ?? "") != value) {
      return "Invalid Email address";
    }
    return null;
  }

  Future getCameraImage() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile;
    pickedFile = (await picker.pickImage(
      source: ImageSource.camera,
    ));
    setState(() {
      if (pickedFile != null) {
        // _images?.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            imagePath: pickedFile!.path,
          ),
        ));
      } else {
        //print('No image selected.');
      }
    });
  }

  Future getFileImage() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile;
    pickedFile = (await picker.pickImage(
      source: ImageSource.gallery,
    ));
    setState(() {
      if (pickedFile != null) {
        // _images?.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            imagePath: pickedFile!.path,
          ),
        ));
      }
    });
  }

}
