// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/components/button.dart';
import 'package:flutter_app/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text editing controllers

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

//sign user in
void signIn() async{
  //show loading circle
  showDialog(
    context: context, 
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  //try sign in
  try{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailTextController.text, 
    password: passwordTextController.text,
  );

  //pop loading circle
  if(context.mounted) Navigator.pop(context);
  } on FirebaseAuthException catch (e){
    //pop loading circle
    Navigator.pop(context);
    //display error message
    displayMessage(e.code);
  }
}

//display a dialogue message
void displayMessage(String message){
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(message),
    ),    
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
            // logo
             const Icon(
              Icons.lock,
              size: 100,
              ),
            
              const SizedBox(height: 50),
            
            // welcome back message
            Text(
              "Welcome back, you've been missed!",
              style: TextStyle(color: Colors.grey[700],
                ),
              ),
            
            const SizedBox(height: 25),
            
            // email textfield
            MyTextField(
              controller: emailTextController, 
              hinText: 'Email', 
              obscureText: false,
              ),
            
            const SizedBox(height: 10),

            // password textfield
            MyTextField(
              controller: passwordTextController, 
              hinText: 'Password', 
              obscureText: true,
            ),
            

            const SizedBox(height: 24),

            // sign in button

            MyButton(onTap: signIn, 
            text: 'Sign In',
            ),
            
            const SizedBox(height: 25),

            //go to register form page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member?", 
                style: TextStyle(
                  color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    "Register now", 
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),      
              ],
            ),
          ),
        ),
      ),
    );
  }
}