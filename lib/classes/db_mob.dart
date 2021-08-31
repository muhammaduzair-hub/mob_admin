import 'package:intl/intl.dart';

class DB_Mob{
  final int mid;
  final String mname;
  final String ms_time;
  final String me_time;
  final String desc;
  final int mflag;
  final int did;

  DB_Mob({this.mid, this.mname, this.ms_time, this.me_time, this.desc, this.mflag, this.did});

  DateFormat dateFormat =DateFormat('yyyy-MM-dd HH:mm');//date formatter

  factory DB_Mob.fromJson(Map<String, dynamic> json){
    return DB_Mob(
      did: json['mdevice'],
      mname: json['mname'],
      ms_time:json['ms_time'].toString() ,
      me_time: json['me_time'].toString() ,
      desc: json['mdesc'],
      mflag: json['mflag'],
      mid: json['mid']
    );
  }
}