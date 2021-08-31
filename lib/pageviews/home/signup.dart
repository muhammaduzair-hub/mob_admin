import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/toast.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/urlstring.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool passshow = false, confirmpassshow = false;
  TextEditingController name_con = TextEditingController();
  TextEditingController email_con = TextEditingController();
  TextEditingController pass_con = TextEditingController();
  TextEditingController confirm_pass_con = TextEditingController();
  bool pass_same = false;
  List<String> category = ["Admin", "Employee"];
  String selectedvalue, sendValuetoDb;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Employee"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.white,),
          onPressed: (){
           setState(() {
             MyColors.myForeColor = Colors.white;
             MyColors.myBackColor = Colors.blue;
           });
           Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: CurvedBar(),
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
              color: Colors.blue,//Color.fromRGBO(66, 165, 255, 1),
            ),
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            height: 600,
            child:  Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                TextField(
                  controller: name_con,
                  style: TextStyle(
                    color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                  ),
                  decoration: InputDecoration(
                    labelText: "Name",
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
                      Icons.person, color: Colors.white,
                      //size: 12,
                    ),
                  ),

                ),
                SizedBox(height: 20,),
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
                SizedBox(height: 20,),


                TextField(
                  onChanged: (va){
                    setState(() {
                      pass_same= confirm_pass_con.text == pass_con?true:false;
                    });
                    },
                  controller: confirm_pass_con,
                  style: TextStyle(
                      color: pass_con.text == confirm_pass_con.text? Colors.white:Colors.red//Color.fromRGBO(66, 165, 255, 1),
                  ),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(
                      color: pass_con.text == confirm_pass_con.text? Colors.white:Colors.red,//Color.fromRGBO(66, 165, 255, 1),
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
                        confirmpassshow?Icons.visibility:Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        setState(() {
                          confirmpassshow = !confirmpassshow;
                        });
                      },
                    ),
                  ),
                  obscureText: confirmpassshow?false:true,
                ),
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.white,
                          width: 2
                      )
                  ),
                  padding: EdgeInsets.only(top: 5,left: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.people, color: Colors.white,),
                      Padding(padding: EdgeInsets.only(left: 15),),
                      DropdownButton(
                        //isExpanded: true,
                        value: selectedvalue,
                        //isExpanded: true,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        focusColor: Colors.blue,
                        dropdownColor: Colors.blue,
                        iconSize: 20,
                        hint: Text("Select Desg                                   ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onChanged: (v){
                          setState(() {
                            selectedvalue = v;
                          });
                        },
                        icon:  Icon(Icons.arrow_drop_down, color: Colors.white,),
                        items: category.map((va){
                          return DropdownMenuItem(
                            value: va,
                            child: Text(va),
                          );
                        }
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      child: ElevatedButton(
                        child: Text("Signup",
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
                          if(pass_con.text != confirm_pass_con.text)
                            {
                              MyToast.showToast("Passwords are not same");
                            }
                          else if(name_con.text != null && pass_con.text !=null && confirm_pass_con.text!= null && email_con.text!=null && selectedvalue!=null )
                            {
                              setState(() {
                                if(selectedvalue == 'Admin') sendValuetoDb= 'admin';
                                if(selectedvalue == 'Employee') sendValuetoDb = 'emp';
                                if(selectedvalue == 'Security') sendValuetoDb = 'security';
                              });
                              print('${sendValuetoDb}');
                              signup();
                              setState(() {
                                MyColors.myForeColor = Colors.white;
                                MyColors.myBackColor = Colors.blue;
                              });
                              Navigator.pop(context);
                            }
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

  void signup() async{
    var res = await http.post(
        Uri.parse(UrlString.url+'Employee/Signup'),
        headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       },
        body: con.jsonEncode(<String, dynamic>{
          "eemail": email_con.text,
          "epass": pass_con.text,
          "ename": name_con.text,
          "edesg": sendValuetoDb,
          "flag": true,
        })
    );
  }
}
