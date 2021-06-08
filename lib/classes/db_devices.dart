class DB_Devices{
  final int did;
  final String dname;
  final int flag;

  DB_Devices({this.did, this.dname, this.flag});

  factory DB_Devices.fromJson(Map<String, dynamic> json)
  {
    return DB_Devices(
      did: json['did'],
      dname: json['dname'],
      flag: json['flag']
    );
  }
}