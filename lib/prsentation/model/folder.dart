import 'dart:convert';

class Folder {
  String id;
  String? folderName;
  DateTime creationDate;

  Folder({
    required this.id,
    this.folderName,
    required this.creationDate,
  });

  // Convert Folder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderName': folderName,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  // Create Folder from JSON
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      folderName: json['folderName'],
      creationDate: DateTime.parse(json['creationDate']),
    );
  }
}
