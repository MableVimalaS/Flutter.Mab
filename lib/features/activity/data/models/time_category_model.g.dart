// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeCategoryModelAdapter extends TypeAdapter<TimeCategoryModel> {
  @override
  final int typeId = 1;

  @override
  TimeCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeCategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimeCategoryModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
