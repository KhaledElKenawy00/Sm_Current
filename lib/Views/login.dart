import 'package:flutter/material.dart';
import 'package:flutter_sqlite_auth_app/Components/button.dart';
import 'package:flutter_sqlite_auth_app/Components/colors.dart';
import 'package:flutter_sqlite_auth_app/Components/textfield.dart';
import 'package:flutter_sqlite_auth_app/JSON/users.dart';
import 'package:flutter_sqlite_auth_app/Views/profile.dart';

import '../SQLite/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Our controllers
  //Controller is used to take the value from user and pass it to database
  final usrName = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;

  final db = DatabaseHelper();
  //Login Method
  //We will take the value of text fields using controllers in order to verify whether details are correct or not
  login() async {
    Users? usrDetails = await db.getUser(usrName.text);
    var res = await db
        .authenticate(Users(usrName: usrName.text, password: password.text));
    if (res == true) {
      //If result is correct then go to profile or home
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(profile: usrDetails)));
    } else {
      //Otherwise show the error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }
//username==>Sm_Current
//passsword==>Sm_Current

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Because we don't have account, we must create one to authenticate
                        //lets go to sign up

                        const Text(
                          "LOGIN",
                          style: TextStyle(color: primaryColor, fontSize: 40),
                        ),
                        Image.asset(
                          "assets/back.png",
                          height: 400,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InputField(
                              hint: "Username",
                              icon: Icons.account_circle,
                              controller: usrName),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: InputField(
                              hint: "Password",
                              icon: Icons.lock,
                              controller: password,
                              passwordInvisible: true),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 50.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            title: const Text("Remember me"),
                            leading: Checkbox(
                              activeColor: primaryColor,
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = !isChecked;
                                });
                              },
                            ),
                          ),
                        ),

                        //Our login button
                        Button(
                            label: "LOGIN",
                            press: () {
                              login();
                            }),

                        isLoginTrue
                            ? Text(
                                "Username or password is incorrect",
                                style: TextStyle(color: Colors.red.shade900),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                // Expanded(
                //   child: Card(
                //     color: Colors.white,
                //     child: Image.asset(
                //       "assets/electric_signal.png",
                //       height: MediaQuery.of(context).size.height,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
