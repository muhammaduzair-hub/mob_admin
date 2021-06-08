import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/urlstring.dart';

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
        ListTile(
          minLeadingWidth: double.infinity,
          title: Text("Mob Quantity", style: TextStyle(color: Colors.blue),),
          trailing: Text("$mobquantity", style: TextStyle(color: Colors.blue)),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(120, 0, 50, 0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                color: Colors.blue,
                onPressed: (){
                  setState(() {
                    mobquantity+=1;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.minimize),
                color: Colors.blue,
                onPressed: (){
                  setState(() {
                    mobquantity-=1;
                  });
                },
              ),
            ],
          ),
        ),
        Divider(color: Colors.blue, height: 15,),
        Padding(
          padding: EdgeInsets.all(100),
          child: Container(
            color: Colors.blue,
            child: ElevatedButton(
              child: Text("Show Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              onPressed: ()=>Navigator.pushNamed(context, "emplist"),
            ),
          ),
        ),
      ],
    );
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
            Navigator.pop(context);
          },
        )
      ),
      bottomNavigationBar: CurvedBar(),
      body: listview() ,
    );
  }
}


