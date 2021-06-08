class DB_Zone{
  final int zid;
  final double zlat;
  final double zlong;
  final String zname;
  final int flag;
  final int km;
  final String emp;

  DB_Zone({this.km,this.zid, this.zlat, this.zlong, this.zname, this.flag, this.emp});

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