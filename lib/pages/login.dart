import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mob_admin_panel/UserLoign/showzone.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'dart:convert' as con;

import 'package:mob_admin_panel/pageviews/home/homeview.dart';
import 'package:mob_admin_panel/pageviews/home/loginperson.dart';
import 'package:mob_admin_panel/pageviews/zone/showdetail.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool passshow = false;
  TextEditingController email_con = TextEditingController();
  TextEditingController pass_con = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Image(
              image: AssetImage("asset/images/2.png"),
              height: 200,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
              color: Color.fromRGBO(66, 165, 255, 1),
            ),
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            height: 600,
            child:  Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100,),
                TextField(
                  controller: email_con,
                  style: TextStyle(
                    color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                  ),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 42,vertical: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                          width: 2
                      ),
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.email, color: Colors.white,
                      //size: 12,
                    ),
                  ),

                ),
                SizedBox(height: 20,),
                TextField(
                  controller: pass_con,
                  style: TextStyle(
                      color: Colors.white//Color.fromRGBO(66, 165, 255, 1),
                  ),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 42,vertical: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                          width: 2
                      ),
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.admin_panel_settings, color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passshow?Icons.visibility:Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        setState(() {
                          passshow = !passshow;
                        });
                      },
                    ),
                  ),
                  obscureText: passshow?false:true,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){},
                    child: Text('                                     Forget Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      child: ElevatedButton(
                        child: Text("Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)
                            ),
                            primary: Colors.white,
                            onPrimary: Colors.white
                        ),
                        onPressed: (){
                          login();
                        },
                      ),
                    ),


                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

 login() async{
    String e= email_con.text;
    String p = pass_con.text;
    var res = await http.get(
        Uri.parse(
            UrlString.url+'employee/adminlogin?email=$e&pass=$p')
    );

    setState(() {
      pass_con.text = "";
    });

    if(res.statusCode == 200) {
      DB_Emp e;
      setState(() {
        e = DB_Emp.fromJson(con.jsonDecode(res.body));
      });
      if(e.edesg == "emp"){
        DB_Zone z;
        var res = await http.get(
            Uri.parse(
                UrlString.url+'Zones/getzone?eemail=${e.email}')
        );
        if(res.statusCode == 200){

          setState(() {
            email_con.text= "";
          });
            z = DB_Zone.fromJson(con.jsonDecode(res.body));
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowZone(selectedzone:z,),));
          }
      }
      else {
          setState(() {
            LoginPerson.loginuser = e;
          });

          setState(() {
            email_con.text= "";
          });

          Navigator.pushNamed(context, 'home');
        }

      // Navigator.push(context, MaterialPageRoute(
      //     builder: (context) => HomeView(loginuser:LoginPerson.loginuser)
      // ));
    }
    else {
      MyToast.showToast("SomeThing went wrong");
    }
 }

  getempszone(String email) async {



 }

}

