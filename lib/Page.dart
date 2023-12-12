import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ResponseModel.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  String api = dotenv.get("token" , fallback: "");

  TextEditingController Q_number = new TextEditingController();
  TextEditingController quiz_topic = new TextEditingController();

  late ResponseModel _responseModel;
   String _responseText = "";
   String error_message = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Container(
            child: const Center(
              child: Text(style: TextStyle(fontSize: 23, color: Colors.white),
                  'Welcome to the AI Quiz Generator'),
            ),
          ),
        ),
        body: SingleChildScrollView(

          child: Container(

            child: Center(
              child: Container(
                width: 450,
                child:
                  Column(
                    children: [
                      Text(""),
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            error_message = "";
                            _responseText = "";
                          });
                        },
                        controller: Q_number,
                        decoration: const InputDecoration(
                          label: Text('Number of Questions',style: TextStyle(color: Colors.white)),
                          filled: true,
                          fillColor: Colors.red,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Write the number of questions you want to generate(max 8)',

                        ),
                        style: TextStyle(color: Colors.white),

                      ),
                      SizedBox(height: 16,),
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            error_message = "";
                            _responseText = "";
                          });
                        },
                        controller: quiz_topic,
                        decoration: const InputDecoration(
                          label: Text('Quiz topic', style: TextStyle(color: Colors.white),),
                          hintText: 'Write the topic of the quiz',
                          hintStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.red,

                        ),
                        style: TextStyle(color: Colors.white),

                      ),
                      SizedBox(height: 25,),

                      ElevatedButton(onPressed: () async {

                        if(Q_number.text.isNotEmpty && quiz_topic.text.isNotEmpty) {
                          if (!(double.tryParse(Q_number.text) == null)) {
                            int x = int.parse(Q_number.text);
                            if (x <= 0 || x > 8) {
                              setState(() {
                                error_message = "Invalid Input";
                              });
                            }
                            else {
                              final response = await http.post(
                                  Uri.parse(
                                      'https://api.openai.com/v1/completions'),

                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer ${dotenv.env['token']}'
                                  },
                                  body: jsonEncode(
                                      {
                                        'model': 'text-davinci-003',
                                        'prompt': 'Create a quiz with ' +
                                            Q_number.text +
                                            ' questions about ' +
                                            quiz_topic.text +
                                            ', with each question having 4 options and give the answers at the end',
                                        'max_tokens': 300,
                                        'temperature': 0,
                                        'top_p': 1
                                      }
                                  )
                              );

                              setState(() {
                                print(response.body);
                                _responseModel =
                                    ResponseModel.fromJson(response.body);
                                _responseText =
                                _responseModel.choices[0]['text'];
                                print(_responseText);
                                //TextPage( s: _responseText);
                              });
                            }
                          }
                          else{
                            setState(() {
                              error_message = "Invalid Input";
                            });
                          }
                        }
                        else{
                         setState(() {
                           error_message = "Insufficient information provided";
                         });
                        }
                      }
                          , child: const Text('Generate'),
                            style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.red,
                             foregroundColor: Colors.white),
                      ),



                      if (_responseText.isNotEmpty)
                          build2(context, _responseText)
                      ,

                      Text(error_message , style: TextStyle(color: Colors.white),)
                    ],
                  ),

              ),
            ),
          ),
        ),

      ),
    );
  }
  /*Widget t(BuildContext context, String s){
    return  AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          s,
          textStyle: const TextStyle(
            fontSize: 25.0,
            fontFamily: 'Horizon',
          ),

        ),
      ],
    );
  }*/
  Widget build2(BuildContext context ,String s) {
    return AnimatedTextKit(
        totalRepeatCount: 1,
        animatedTexts: [
        TypewriterAnimatedText(
        s,
        textStyle: const TextStyle(
        fontSize: 25.0,
        fontFamily: 'Agne',
          color: Colors.white

    ),

    ),
          ColorizeAnimatedText(
            s,
            textStyle: const TextStyle(
              fontSize: 25.0,
              fontFamily: 'Agne',
            ),
            colors: [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
            ],
          ),
    ],
    onTap: () async {
    await Clipboard.setData(ClipboardData(text: s));
        showToast();
    }
    );
  }

  void showToast() => Fluttertoast.showToast(
      msg: "Copied to Clipboard",
      toastLength: Toast.LENGTH_LONG,
      fontSize: 25.0
  );
}




