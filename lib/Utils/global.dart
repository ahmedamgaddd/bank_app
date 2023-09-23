class GlobalVariables {
  static final GlobalVariables _singleton = GlobalVariables._internal();

  factory GlobalVariables() {
    return _singleton;
  }

  GlobalVariables._internal();


  int id=0;
  String name='';
  String email='';
  double currentBalance=0.0;
}