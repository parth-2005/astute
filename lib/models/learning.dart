/*

Name
Image
Description

*/

class Learning {
  String name;
  String image;
  String description;

  Learning({
    required this.name,
    required this.image,
    required this.description,
  });

  factory Learning.fromJson(Map<String, dynamic> json) {
    return Learning(
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'description': description,
    };
  }
  @override
  String toString() {
    return 'Learning(name: $name, image: $image, description: $description)';
  }
}