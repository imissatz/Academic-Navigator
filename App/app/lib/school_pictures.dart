import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class SchoolPicturesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedSchools;

  SchoolPicturesScreen({required this.recommendedSchools});

  Future<Map<String, List<String>>> _loadImages() async {
    // Load the AssetManifest.json
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Create a map to store images for each school
    Map<String, List<String>> schoolImages = {};

    // Iterate over the manifest and collect images for each school
    manifestMap.forEach((key, value) {
      if (key.contains('assets/pictures/')) {
        // Extract the school name from the path
        final parts = key.split('/');
        if (parts.length >= 3) {
          final schoolName = parts[2]; // This assumes the path format is assets/pictures/{schoolName}/image.jpg

          if (schoolImages.containsKey(schoolName)) {
            schoolImages[schoolName]!.add(key);
          } else {
            schoolImages[schoolName] = [key];
          }
        }
      }
    });

    return schoolImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Pictures'),
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: _loadImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading images: ${snapshot.error}'));
          } else {
            final schoolImages = snapshot.data!;
            return ListView.builder(
              itemCount: recommendedSchools.length,
              itemBuilder: (context, index) {
                final school = recommendedSchools[index];
                final schoolName = school['School'].toString().replaceAll(' ', '_').toLowerCase();
                final images = schoolImages[schoolName] ?? [];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school['School'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        images.isNotEmpty
                            ? _buildImageGrid(images)
                            : Text('No images available'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildImageGrid(List<String> imagePaths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return Image.asset(imagePaths[index]);
      },
    );
  }
}
