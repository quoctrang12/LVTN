import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lvtn_admin/home_screen.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _authData = {
    'username': '',
    'password': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  bool hiddenPassword = true, errorLogin = false;

  // String username = '', password = '';
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    _isSubmitting.value = true;
    try {
      if (_authData['username'] == 'admin' &&
          _authData['password'] == '123456') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
                builder: (BuildContext context) => BLEProjectPage(
                      title: 'BLE Indoor Position',
                    )),
            (route) => false);
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Đăng nhập không thành công!!"),
            actions: <Widget>[
              TextButton(
                child: const Text("Thử lại"),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      }
    } catch (error) {}
    _isSubmitting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SingleChildScrollView(
            child: Container(
              color: Colors.blue[50],
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .965,
              child: Stack(alignment: AlignmentDirectional.center, children: [
                // Positioned(
                //   child: Image.asset(
                //     'assets/images/banner.jpg',
                //     width: 280,
                //   ),
                //   top: -7,
                //   right: -120,
                // ),
                Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width * .9,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 145, 217, 240),
                        spreadRadius: 0,
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Login',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontSize: 30,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('Please login to continue',
                          style: TextStyle(
                              color: Color.fromARGB(255, 144, 142, 142),
                              decoration: TextDecoration.none,
                              fontSize: 16)),
                      const SizedBox(
                        height: 30,
                      ),
                      Form(
                          key: _formKey,
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        _authData['username'] = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                          color: Color.fromARGB(
                                              255, 105, 103, 103),
                                        ),
                                        labelStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 82, 81, 81)),
                                        labelText: 'Username',
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black))),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: TextField(
                                    obscureText: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _authData['password'] = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Color.fromARGB(
                                              255, 105, 103, 103),
                                        ),
                                        labelStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 82, 81, 81)),
                                        labelText: 'Password',
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black))),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder<bool>(
                                      valueListenable: _isSubmitting,
                                      builder: (context, isSubmitting, child) {
                                        if (isSubmitting) {
                                          return const CircularProgressIndicator();
                                        }
                                        return TextButton(
                                          onPressed: _submit,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .70,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'LOGIN ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                // Positioned(
                //   child: Image.asset(
                //     'assets/images/banner.jpg',
                //     width: 250,
                //   ),
                //   bottom: -8,
                //   left: -140,
                // ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
