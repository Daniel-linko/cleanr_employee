import 'package:clean_r/Base/DataChangeObserver.dart';
import 'package:clean_r/Model/Base/BooleanAttribute.dart';
import 'package:clean_r/Model/Base/EmailAttribute.dart';
import 'package:clean_r/Model/Base/EnumAttribute.dart';
import 'package:clean_r/Model/Base/ModelObject.dart';
import 'package:clean_r/Model/Base/NumericAttribute.dart';
import 'package:clean_r/Model/Base/TextAttribute.dart';
import 'package:clean_r/Model/Base/ZipCodeAttribute.dart';
import 'package:cleanr_employee/UI/Employee/PermitType.dart';

import 'Employee.dart';

class EmployeeInformationModel extends ModelObject {
  final Employee employee;

  static const String _lastNameDBField = 'Last Name';
  static const String _firstNameDBField = 'First Name';
  static const String _emailDBField = 'Email';
  static const String _zipCodeDBField = 'Zip Code';
  static const String _ironingSkillDBField = 'Ironing Skill';
  static const String _minWeeklyHoursDBField = 'Min Weekly Hours';
  static const String _maxWeeklyHoursDBField = 'Max Weekly Hours';
  static const String _phoneDBField = 'Phone';
  static const String _nationalityPermitDBField = 'Nationality/Permit';
  TextAttribute? lastNameAttribute;
  TextAttribute? firstNameAttribute;
  EmailAttribute? emailAttribute;
  ZipCodeAttribute? zipCodeAttribute;
  BooleanAttribute? ironingSkill;
  NumericAttribute? minWeeklyHours;
  NumericAttribute? maxWeeklyHours;
  TextAttribute? phoneNumberAttribute;
  EnumAttribute<NationalityPermitType>? nationalityPermit;

  EmployeeInformationModel(this.employee) {
    lastNameAttribute = TextAttribute(this, null);
    firstNameAttribute = TextAttribute(this, null);
    emailAttribute = EmailAttribute(this, null);
    zipCodeAttribute = ZipCodeAttribute(this, null);
    ironingSkill = BooleanAttribute(this, null);
    minWeeklyHours = NumericAttribute(this, null, 1);
    maxWeeklyHours = NumericAttribute(this, null, 1);
    phoneNumberAttribute = TextAttribute(this, null);
    nationalityPermit = EnumAttribute<NationalityPermitType>(
        this, null, NationalityPermitType.permitTypes.values.first);
  }

  EmployeeInformationModel.fromMap(this.employee, Map<String, dynamic> map)
      : super.fromMap(map) {
    this.fromMap(map, null);
  }

  @override
  void addToMap(Map<String, dynamic> map) {
    map.addAll({_lastNameDBField: lastNameAttribute!.value});
    map.addAll({_firstNameDBField: firstNameAttribute!.value});
    map.addAll({_emailDBField: emailAttribute!.value});
    map.addAll({_ironingSkillDBField: ironingSkill!.value});
    map.addAll({_minWeeklyHoursDBField: minWeeklyHours!.value});
    map.addAll({_maxWeeklyHoursDBField: maxWeeklyHours!.value});
    map.addAll({_phoneDBField: phoneNumberAttribute!.value});
    map.addAll({_nationalityPermitDBField: nationalityPermit!.value});
  }

  void fromMap(Map<String, dynamic> map, DataChangeObserver? observer) {
    super.fromMap(map, observer);
    lastNameAttribute =
        TextAttribute.fromMap(map, _lastNameDBField, true, this, null);
    firstNameAttribute =
        TextAttribute.fromMap(map, _firstNameDBField, true, this, null);
    emailAttribute =
        EmailAttribute.fromMap(map, _emailDBField, true, this, null);
    zipCodeAttribute =
        ZipCodeAttribute.fromMap(map, _zipCodeDBField, true, this, null);
    ironingSkill =
        BooleanAttribute.fromMap(map, _ironingSkillDBField, true, this, null);
    minWeeklyHours = NumericAttribute.fromMap(
        map, _minWeeklyHoursDBField, true, 1, this, null);
    maxWeeklyHours = NumericAttribute.fromMap(
        map, _maxWeeklyHoursDBField, true, 1, this, null);
    phoneNumberAttribute =
        TextAttribute.fromMap(map, _phoneDBField, true, this, null);
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
}
