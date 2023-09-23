class DBModel{


final int? id;
final String? name;
final String? email;
final double? currentBalance;


DBModel({
this.id,
required this.name,
required this.currentBalance,
required this.email

});


DBModel.fromMap(Map<String,dynamic> res):

id=res['id'],
name=res['name'],
email=res['email'],
currentBalance=res['currentBalance'];


Map<String ,Object?> toMap(){

  return {
    'id':id,
    'email':email,
    'name':name,
    'currentBalance':currentBalance,


  };
}









}