import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import 'package:instagram_flutter/resources/firebase_auth_methods.dart';
import 'package:instagram_flutter/screens/sign_up_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  void loginUser() async{
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text, 
      password: _passwordController.text
      );
    print("Result is ${res}");
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignUp() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SignUpScreen()
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
              const SizedBox(height: 64),
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
                //button login
              InkWell(
                child: Container(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    child: _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )
                    )
                    :Text("Login"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[800]
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(child: Container(), flex: 2),
                //Transitioning to signing up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text("Don't have an account?",
                    // style: TextStyle(
                    //   fontWeight: FontWeight.bold
                    //   ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical:8),
                  ),
                  GestureDetector(
                    onTap: navigateToSignUp,
                    child: Container(
                      child: const Text("Sign Up",
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