import 'package:flutter/material.dart';
import 'recommended_schools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

class DropdownWidget extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  DropdownWidget({
    required this.labelText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: DropdownButtonFormField<String>(
        items: items.map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Field required' : null,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? selectedMunicipal;
  String? selectedPerformance;
  String? selectedReligion;
  String? selectedBoardingDay;
  String? selectedGender;
  String? selectedRating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'ACADEMIC NAVIGATOR',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownWidget(
              labelText: 'Choose your desired Municipal',
              items: [
                'Ilala, Dar- Es - Salaam, Tanzania',
                'Temeke, Dar- Es - Salaam, Tanzania',
                'Kinondoni, Dar- Es - Salaam, Tanzania',
                'Kigamboni, Dar- Es - Salaam,,Tanzania',
                'Ubungo, Dar- Es - Salaam,Tanzania',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedMunicipal = newValue;
                });
              },
            ),
            DropdownWidget(
              labelText:
                  'Overall School Performance (1- Excellent to 5 - Very Poor)',
              items: [
                '1',
                '2',
                '3',
                '4',
                '5',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedPerformance = newValue;
                });
              },
            ),
            DropdownWidget(
              labelText: 'Which Religion do you prefer?',
              items: [
                'Christianity',
                'Islam',
                'Both',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedReligion = newValue;
                });
              },
            ),
            DropdownWidget(
              labelText: 'Which Gender do you prefer?',
              items: [
                'Boys',
                'Girls',
                'Both',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue;
                });
              },
            ),
            DropdownWidget(
              labelText: 'Boarding or Day',
              items: ['Boarding', 'Day', 'Both'],
              onChanged: (String? newValue) {
                setState(() {
                  selectedBoardingDay = newValue;
                });
              },
            ),
            DropdownWidget(
              labelText: 'Choose your Ratings (1 - Poor to 5 - Outstanding)',
              items: [
                '1',
                '2',
                '3',
                '4',
                '5',
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedRating = newValue;
                });
              },
            ),
            ElevatedButton(
              onPressed: _submitData, // Call the function to submit data
              child: const Text('Submit Preferences'), // Button text
            ),
          ],
        ),
      ),
    );
  }

  void _submitData() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedSchoolsScreen(
          selectedMunicipal: selectedMunicipal!,
          selectedPerformance: selectedPerformance!,
          selectedReligion: selectedReligion!,
          selectedBoardingDay: selectedBoardingDay!,
          selectedGender: selectedGender!,
          selectedRating: selectedRating!,
        ),
      ),
    );
  }
}
