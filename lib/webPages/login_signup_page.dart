import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/user_model.dart';

import '../defaultColors/default_colors.dart';

class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  bool doesUserWantToSignUp = false;
  Uint8List? selectedImage;
  bool errorInPicture = false;
  bool errorInName = false;
  bool errorInEmail = false;
  bool errorInPassword = false;
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool loadingOn = false;

  chooseImage() async {
    FilePickerResult? chosenImageFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      chosenImageFile!.files.single.bytes;
    });
  }

  uploadImageToStorage(UserModel userData) {

  }

  signUpUserNow(nameInput, emailInput, passwordInput) async {
    //TODO: 1. create a new user in firebase authentication
    final userCreated = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailInput, password: passwordInput);
    //TODO: 2. upload image to storage
    String? uidOfCreatedUser = userCreated.user!.uid;
    if (uidOfCreatedUser.isNotEmpty) {
      final userData =
          UserModel(uidOfCreatedUser, nameInput, emailInput, passwordInput);
      uploadImageToStorage(userData);
    }
  }

  formValidation() {
    setState(() {
      loadingOn = true;
      errorInEmail = false;
      errorInPassword = false;
      errorInName = false;
      errorInPicture = false;
    });

    String nameInput = nameTextEditingController.text.trim();
    String emailInput = emailTextEditingController.text.trim();
    String passwordInput = passwordTextEditingController.text.trim();

    if (emailInput.isNotEmpty && emailInput.contains("@")) {
      if (passwordInput.isNotEmpty && passwordInput.length > 7) {
        if (doesUserWantToSignUp == true) //signup form
        {
          if (nameInput.isNotEmpty && nameInput.length >= 3) {
            signUpUserNow(nameInput, emailInput, passwordInput);
          } else {
            var snackBar = const SnackBar(
              content: Center(
                child: Text("Name is not valid"),
              ),
              backgroundColor: DefaultColors.primaryColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            setState(() {
              loadingOn = !true;
            });
          }
        } else //login form
        {}
      } else {
        var snackBar = const SnackBar(
          content: Center(
            child: Text("Password is not valid"),
          ),
          backgroundColor: DefaultColors.primaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        setState(() {
          loadingOn = !true;
        });
      }
    } else {
      var snackBar = const SnackBar(
        content: Center(
          child: Text("Email is not valid"),
        ),
        backgroundColor: DefaultColors.primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      loadingOn = !true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: DefaultColors.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                color: DefaultColors.primaryColor,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Card(
                    elevation: 6,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      width: 500,
                      child: Column(
                        children: [
                          //profile img
                          Visibility(
                            visible: doesUserWantToSignUp,
                            child: ClipOval(
                                child: selectedImage != null
                                    ? Image.memory(
                                        selectedImage!,
                                        width: 124,
                                        height: 124,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "../images/avatar.png",
                                        width: 124,
                                        height: 124,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                          //outlined choose picture button
                          Visibility(
                            visible: doesUserWantToSignUp,
                            child: OutlinedButton(
                              onPressed: () {
                                chooseImage();
                              },
                              style: errorInPicture
                                  ? OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 3, color: Colors.red))
                                  : null,
                              child: const Text("Choose Picture"),
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          //name text field
                          Visibility(
                            visible: doesUserWantToSignUp,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              controller: nameTextEditingController,
                              decoration: InputDecoration(
                                  hintText: "Write a valid name",
                                  labelText: "Name",
                                  suffixIcon: const Icon(Icons.person_outline),
                                  enabledBorder: errorInName
                                      ? const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.red))
                                      : null),
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          //email text field

                          TextField(
                            keyboardType: TextInputType.text,
                            controller: emailTextEditingController,
                            decoration: InputDecoration(
                                hintText: "Write a valid email",
                                labelText: "Email",
                                suffixIcon:
                                    const Icon(Icons.mail_outline_outlined),
                                enabledBorder: errorInEmail
                                    ? const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3, color: Colors.red))
                                    : null),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          //password text field

                          TextField(
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            controller: passwordTextEditingController,
                            decoration: InputDecoration(
                                hintText: doesUserWantToSignUp
                                    ? "Must have greater than 7 characters"
                                    : "Write your correct password",
                                labelText: "Password",
                                suffixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                enabledBorder: errorInPassword
                                    ? const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3, color: Colors.red))
                                    : null),
                          ),
                          const SizedBox(
                            height: 22,
                          ),

                          //login signup button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                formValidation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DefaultColors.primaryColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: loadingOn
                                    ? const SizedBox(
                                        height: 19,
                                        width: 19,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        doesUserWantToSignUp
                                            ? "Sign Up"
                                            : "Login",
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                              ),
                            ),
                          ),

                          //toggle button
                          Row(
                            children: [
                              const Text("Login"),
                              Switch(
                                value: doesUserWantToSignUp,
                                onChanged: (bool value) {
                                  setState(() {
                                    doesUserWantToSignUp = value;
                                  });
                                },
                              ),
                              const Text("Sign Up"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
