import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/demo/demoaddzone.dart';
import 'package:mob_admin_panel/pageviews/mob/mob.dart';

class HomeView extends StatefulWidget {
  final DB_Emp loginuser;
  const HomeView({Key key, this.loginuser}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState(loginuser);
}


class _HomeViewState extends State<HomeView> {
  final DB_Emp loginuser;
  _HomeViewState(this.loginuser);

  List<DB_Emp> emplist ;
  int mobquantity = 20;


  Widget listviewemp(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: emplist.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) => Column(
        children: [
          ListTile(
            leading: CircleAvatar(
                child: Icon(Icons.person, color: Colors.white,),
              backgroundColor: Colors.blue,
            ),
            //contentPadding: EdgeInsets.all(30),
            title: Text(emplist[i].ename, style: TextStyle(fontSize: 25 ,fontWeight: FontWeight.bold, color: Colors.blue),),
            subtitle:  Text(emplist[i].edesg, style: TextStyle(color: Colors.blue),),
            trailing: emplist[i].eflag?
            Text("Available", style: TextStyle(color: Colors.green),)
                :
            Text("Not Available", style: TextStyle(color: Colors.red),),
          ),
          Divider(color: Colors.blue, height: 15,)
        ],
      ),
    );
  }

  getemp() async {
    var res =await  http.get(Uri.parse(UrlString.url+'Employee/getall'));
    if(res.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(res.body);
        emplist = list.map((e) => DB_Emp.fromJson(e)).toList();
      });
    }
    else{
      setState(() {
        emplist = null;
      });
    }
  }

  Widget listview(){
    return ListView(
      children: [
        Container(
          color: Colors.blue[300],
          height: 200,
          width: double.infinity,
          child: Center(
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.black12,
              backgroundImage:  AssetImage('asset/images/person-male.png', ),
            ),
          ),
        ),
        SizedBox(height: 30,),
        Center(
          child: Column(
            children: [
              Text('${loginuser.ename}', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 30),),
              Padding(padding: EdgeInsets.all(5)),
              Text('${loginuser.email}', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(
                height: 10,
              )
            ],
          )
        ),
        Divider(color: Colors.blue, height: 15,),
        Padding(padding: EdgeInsets.only(left: 40),
          child: Text(
            "Employees",
            style: TextStyle(color: Colors.blue, fontSize: 15),
          ),),
        Divider(color: Colors.blue, height: 15,),
        Flexible(
          child: Container(
            height: 360,
            child: emplist==null?Center(child: CircularProgressIndicator(),):listviewemp(),
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.all(100),
        //   child: Container(
        //     color: Colors.blue,
        //     child: ElevatedButton(
        //       child: Text("Show Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        //       onPressed: ()=>Navigator.pushNamed(context, "emplist"),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        Navigator.of(context).pop();
        break;
      case 'DemoPage':
        Navigator.push(context, MaterialPageRoute(builder: (context) => DemoAddZone(),));
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getemp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.white,),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,size: 20,),
            onPressed: ()=>getemp(),
          ),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'DemoPage'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      bottomNavigationBar: CurvedBar(),
      body: listview() ,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            MyColors.myForeColor = Colors.blue;
            MyColors.myBackColor = Colors.white;
          });
          Navigator.pushNamed(context, 'signup');
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ) ,
      ),
    );
  }
}


