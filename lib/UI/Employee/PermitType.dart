import 'package:clean_r/Base/Enum.dart';

class NationalityPermitType extends Enum {
  final String rep;
  static Map<String, NationalityPermitType> permitTypes = {
    "B": NationalityPermitType("B"),
    "C": NationalityPermitType("C"),
    "CH": NationalityPermitType("CH")
  };

  NationalityPermitType(this.rep);

  @override
  Enum fromRepresentation(String representation) {
    Enum? fromR = permitTypes[representation];
    if (fromR == null) {
      return permitTypes["CH"]!;
    } else {
      return fromR;
    }
  }

  @override
  List<Enum> modalities() {
    return permitTypes.values.toList();
  }

  @override
  String representation() {
    return rep;
  }

  @override
  void addToMap(Map<String, dynamic> map) {
    // TODO: implement addToMap
  }

  @override
  String path() {
    // TODO: implement path
    throw UnimplementedError();
  }

  @override
  String typeName() {
    // TODO: internationalization (on widget level I guess)
    return "Nationality/Permit";
  }
}
