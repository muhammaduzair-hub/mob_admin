class DB_Zone{
  final int zid;
  final double zlat;
  final double zlong;
  final String zname;
  final int flag;
  final int km;
  final String emp;

  //these 4 for demo
  String status;
  String distancekm;
  double time;
  bool isshow;

  DB_Zone({this.km,this.zid, this.zlat, this.zlong, this.zname, this.flag, this.emp, this.status, this.time, this.isshow=false});

  factory DB_Zone.fromJson(Map<String, dynamic> json)
  {
    return DB_Zone(
      zid: json["zid"],
      zlat: json["zlatitude"],
      zlong: json["zlongitude"],
      zname: json["zname"],
      flag: json["zflag"],
      km: json['km'],
      emp: json['employee']
    );
  }

}