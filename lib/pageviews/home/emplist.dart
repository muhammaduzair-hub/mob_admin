import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/urlstring.dart';

class EmpList extends StatefulWidget {
  @override
  _EmpListState createState() => _EmpListState();
}

class _EmpListState extends State<EmpList> {
  List<DB_Emp> emplist ;
  Widget listview(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: emplist.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) => Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getemp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedBar(),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      appBar: AppBar(
        title: Text("Employees"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,size: 20,),
            onPressed: ()=>getemp(),
          ),
        ],
      ),
      body: emplist==null?
          //Center(child: Text("NO employee yet", style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),)
         Center(child: CircularProgressIndicator())
          :listview(),
    );
  }
}
