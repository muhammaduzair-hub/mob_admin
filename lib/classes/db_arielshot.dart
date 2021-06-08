class DB_ArielShot{
  final int pid;
  final String pname;
  final String paddres;
  final double platitude;
  final double plongitude;
  final DateTime pdatetime;
  final int mid;
  final int pmobquantity;
  final int picno;
  final String speed;

  DB_ArielShot({
    this.pid,
    this.pname,
    this.paddres,
    this.platitude,
    this.plongitude,
    this.pdatetime,
    this.mid,
    this.pmobquantity,
    this.picno,
    this.speed
  });

  factory DB_ArielShot.fromJson(Map<String, dynamic> json){
    return DB_ArielShot(
        mid: json['mid'],
        paddres: json['Paddress'],
        pdatetime: DateTime.parse(json['Ptime']),
        picno: json['mpic_no'],
        pid: json['pid'],
        platitude: json['Platitude'],
        plongitude: json['Plongitude'],
        pmobquantity: json['pmobquantity'],
        pname: json['Pname'],
        speed: json['pspeed']
    );
  }
}