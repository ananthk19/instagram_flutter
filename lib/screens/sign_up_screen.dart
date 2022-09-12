import 'dart:typed_data';

import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/resources/firebase_auth_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/image_select.dart';
import 'package:instagram_flutter/utils/snack_bar_util.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  Uint8List? image;
  bool _isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _userNameController.dispose();
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      image = img;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
                      email: _emailController.text, 
                      password: _passwordController.text, 
                      userName: _userNameController.text, 
                      bio: _bioController.text,
                      file: image!,
                      );
                      print("Result is $res");
    if(res != 'success'){
      showSnackBar(res,context);
    }
    else {
      navigateToLogin();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen()
      ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),

                //svg image
              SvgPicture.asset("lib/assets/ic_instagram.svg", 
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(height: 30),
              Stack(
                children: [
                  image != null
                  ? CircleAvatar(
                    radius: 64,
                    backgroundImage: MemoryImage(image!),                    
                  )
                  : CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage('https://i.pinimg.com/474x/65/25/a0/6525a08f1df98a2e3a545fe2ace4be47.jpg'),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      ))
                ],
              ),
              SizedBox(height: 10,),
                //text field input for email
              TextFieldInput(
                textEditingController: _emailController, 
                hint_text: "Email....", 
                textInputType: TextInputType.emailAddress
              ),
              const SizedBox(height: 20),
                // text field input for password
              TextFieldInput(
                textEditingController: _passwordController, 
                hint_text: "Password....", 
                textInputType: TextInputType.text,
                isPassw: true,
              ),
              const SizedBox(height: 20),
                //textfield input for userName
              TextFieldInput(
                textEditingController: _userNameController, 
                hint_text: "UserName....", 
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 20),
                //textfield input for bio
              TextFieldInput(
                textEditingController: _bioController, 
                hint_text: "Bio....", 
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 20),
                //button login
              InkWell(
                child: Container(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    child: _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                    : Text("SignUp"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[800]
                    ),
                    onPressed: signUpUser,
                  ),
                ),
              ),
              Flexible(child: Container(), flex: 2),
                //Transitioning to signing up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text("Already have an account?"),
                    padding: const EdgeInsets.symmetric(vertical:8),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      child: const Text("Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical:8),
                    ),
                  )
                ],
                )
            ]
            ),
        ) 
       ),
    );
  }
}