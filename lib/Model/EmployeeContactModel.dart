import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Base/DataChangeObserver.dart';
import 'package:clean_r/Model/Base/BooleanAttribute.dart';
import 'package:clean_r/Model/Base/ContactModel.dart';
import 'package:clean_r/Model/Base/EnumAttribute.dart';
import 'package:clean_r/Model/Base/NumericAttribute.dart';
import 'package:clean_r/Model/Base/ZipCodeAttribute.dart';
import 'package:cleanr_employee/UI/Employee/PermitType.dart';

import 'Employee.dart';

class EmployeeContactModel extends ContactModel {
  final Employee employee;

  static const String _zipCodeDBField = 'Zip Code';
  static const String _ironingSkillDBField = 'Ironing Skill';
  static const String _minWeeklyHoursDBField = 'Min Weekly Hours';
  static const String _maxWeeklyHoursDBField = 'Max Weekly Hours';
  static const String _nationalityPermitDBField = 'Nationality/Permit';
  late ZipCodeAttribute zipCodeAttribute;
  late BooleanAttribute ironingSkill;
  late NumericAttribute minWeeklyHours;
  late NumericAttribute maxWeeklyHours;
  late EnumAttribute<NationalityPermitType> nationalityPermit;

  EmployeeContactModel(this.employee) : super() {
    zipCodeAttribute = ZipCodeAttribute(this, null, 1234);
    ironingSkill = BooleanAttribute(this, null, false);
    minWeeklyHours = NumericAttribute(this, null, 1, 0);
    maxWeeklyHours = NumericAttribute(this, null, 1, 40);
    nationalityPermit = EnumAttribute<NationalityPermitType>(
        this, null, NationalityPermitType.permitTypes["CH"]!);
  }

  EmployeeContactModel.fromMap(this.employee, Map<String, dynamic> map)
      : super.fromMap(map) {
    this.fromMap(map, null);
  }

  @override
  void addToMap(Map<String, dynamic> map) {
    map.addAll({_ironingSkillDBField: ironingSkill.value});
    map.addAll({_minWeeklyHoursDBField: minWeeklyHours.value});
    map.addAll({_maxWeeklyHoursDBField: maxWeeklyHours.value});
    map.addAll({_nationalityPermitDBField: nationalityPermit.value});
  }

  void fromMap(Map<String, dynamic> map, DataChangeObserver? observer) {
    super.fromMap(map, observer);
    zipCodeAttribute =
        ZipCodeAttribute.fromMap(map, _zipCodeDBField, 1234, true, this, null);
    ironingSkill = BooleanAttribute.fromMap(
        map, _ironingSkillDBField, false, true, this, null);
    minWeeklyHours = NumericAttribute.fromMap(
        map, _minWeeklyHoursDBField, true, 1, 0, this, null);
    maxWeeklyHours = NumericAttribute.fromMap(
        map, _maxWeeklyHoursDBField, true, 1, 40, this, null);
    nationalityPermit = EnumAttribute<NationalityPermitType>.fromMap(
        map,
        _nationalityPermitDBField,
        true,
        this,
        null,
        NationalityPermitType.permitTypes.values.first);
  }

  @override
  String path() {
    return employee.employeeInformationModelCollectionPath() + "/1";
  }

  @override
  CleanRUser user() {
    return employee;
  }

  bool isComplete() {
    return firstNameAttribute.value.isNotEmpty &&
        lastNameAttribute.value.isNotEmpty;
  }
}
