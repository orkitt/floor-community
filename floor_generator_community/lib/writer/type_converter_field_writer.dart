import 'package:code_builder/code_builder.dart';
import 'package:floor_generator_community/misc/extension/string_extension.dart';
import 'package:floor_generator_community/writer/writer.dart';

class TypeConverterFieldWriter extends Writer {
  final String _typeConverterName;

  TypeConverterFieldWriter(final String typeConverterName)
      : _typeConverterName = typeConverterName;

  @override
  Spec write() {
    return Field((builder) => builder
      ..name = '_${_typeConverterName.decapitalize()}'
      ..modifier = FieldModifier.final$
      ..assignment = Code('$_typeConverterName()'));
  }
}
