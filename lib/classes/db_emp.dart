class DB_Emp{
  final String email;
  final String epass;
  final String ename;
  final String edesg;
  final bool eflag;

  DB_Emp({this.email, this.epass, this.ename, this.edesg, this.eflag});

  factory DB_Emp.fromJson(Map<String, dynamic> json){
    return DB_Emp(
      email: json['eemail'],
      epass: json['epass'],
      edesg: json['edesg'],
      eflag: json['flag'],
      ename: json['ename']
    );
  }
}