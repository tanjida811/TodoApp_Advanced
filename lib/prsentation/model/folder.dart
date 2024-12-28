import 'dart:convert';

class Folder {
  String id;
  String? folderName;
  DateTime creationDate;
  DateTime? modifiedDate;

  // Constructor where the default creationDate is the current date and time if not provided
  Folder({
    required this.id,
    this.folderName,
    DateTime? creationDate,
    this.modifiedDate,
  }) : creationDate = creationDate ?? DateTime.now(); // Use current dat

  // Convert Folder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderName': folderName,
      'creationDate': creationDate.toIso8601String(),
      'modifiedDate': modifiedDate?.toIso8601String(),
    };
  }

  // Create Folder from JSON
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      folderName: json['folderName'],
      creationDate: DateTime.parse(json['creationDate']),
      modifiedDate: json['modifiedDate'] != null ? DateTime.parse(json['modifiedDate']) : null,

    );
  }
}
