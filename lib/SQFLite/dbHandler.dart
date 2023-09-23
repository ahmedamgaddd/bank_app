
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

import 'db_model.dart';


class DBHelper{

  static Database? _db;

  Future<Database?> get db async{
    if(_db!=null){
      return _db;

    }
    _db=await initDatabase();

    return _db;


  }

  initDatabase() async{
  io.Directory documentDirectory=await getApplicationDocumentsDirectory();
  String path=join(documentDirectory.path,'BankSystem.db');
  var db=await openDatabase(path,version: 1,onCreate: _onCreate);
  return db;

  }

  _onCreate(Database db, int version) async{

    await db.execute("CREATE TABLE bank (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL ,email TEXT NOT NULL , currentBalance DOUBLE NOT NULL)",);


  }


  Future<DBModel> insert(DBModel dbModel) async{

    var dbClient= await db;
    await dbClient!.insert('bank', dbModel.toMap());

    return dbModel;
  }

  
  Future<List<DBModel>> getList() async{

    var dbClient= await db;
    final List<Map<String,Object?>> queryResult=await dbClient!.query('bank');

    return queryResult.map((e) => DBModel.fromMap(e)).toList(); 
  }


    Future<int> deleteUser(int id) async{

    var dbClient= await db;

    return await dbClient!.delete(
      'bank',
      where: 'id=?',
      whereArgs: [id]


    ) ;

    
  }
   Future<int > updateUser(DBModel dbModel) async{

    var dbClient= await db;

    return await dbClient!.update(
      'bank',
      dbModel.toMap(),
      where: 'id=?',
      whereArgs: [dbModel.id]


    ) ;


}}