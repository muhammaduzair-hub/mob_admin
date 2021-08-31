class DB_ZoneDetail{
  final int zdid;
  final double mlat;
  final double mlong;
  final String mtime;
  final String mstatus;
  final int mid;
  final int zid;
  final int mqty;
  final int reachtime;
  //for zone detail
  String mobname;


  DB_ZoneDetail({this.zdid, this.mlat, this.mlong, this.mtime, this.mstatus, this.mid, this.zid, this.mqty, this.reachtime});
  factory DB_ZoneDetail.fromJson(Map<String, dynamic> json)
  {
    return DB_ZoneDetail(
        zdid: json["zdid"],
        mlat: json["mlatitude"],
        mlong: json["mlongitude"],
        mtime: json["mtime"],
        mstatus: json["mstatus"],
        mid: json["mid"],
      zid: json["zid"],
      mqty: json["pmobquantity"],
      reachtime: json["reachtime"]
    );
  }

}