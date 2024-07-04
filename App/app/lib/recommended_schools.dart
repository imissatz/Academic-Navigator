import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'statistics.dart';

class RecommendedSchoolsScreen extends StatefulWidget {
  final String selectedMunicipal;
  final String selectedPerformance;
  final String selectedReligion;
  final String selectedBoardingDay;
  final String selectedGender;
  final String selectedRating;

  RecommendedSchoolsScreen({
    required this.selectedMunicipal,
    required this.selectedPerformance,
    required this.selectedReligion,
    required this.selectedBoardingDay,
    required this.selectedGender,
    required this.selectedRating,
  });

  @override
  _RecommendedSchoolsScreenState createState() => _RecommendedSchoolsScreenState();
}

class _RecommendedSchoolsScreenState extends State<RecommendedSchoolsScreen> {
  List<dynamic> _recommendedSchools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedSchools();
  }

  Future<void> _fetchRecommendedSchools() async {
    // final url = 'http://10.0.2.2:5000/school'; // Your Flask server for emulator URL
    final url = 'http://127.0.0.1:5000/school'; // Your Flask server for website URL



    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'performance': widget.selectedPerformance,
          'location': widget.selectedMunicipal,
          'religion': widget.selectedReligion,
          'stars': widget.selectedRating,
          'gender': widget.selectedGender,
          'boarding/day': widget.selectedBoardingDay,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Log the response to see its content
        print('Response data: $responseData');

        if (responseData is List) {
          setState(() {
            // Round performance values to 2 decimal places
            _recommendedSchools = responseData.map((school) {
              // Helper function to round values safely
              double roundToTwoDecimalPlaces(dynamic value) {
                if (value == null) return 0.0;
                double parsedValue = double.tryParse(value.toString()) ?? 0.0;
                return double.parse(parsedValue.toStringAsFixed(2));
              }

              school['performance'] = roundToTwoDecimalPlaces(school['performance']);
              school['performance_2023'] = roundToTwoDecimalPlaces(school['performance_2023']);
              school['performance_2022'] = roundToTwoDecimalPlaces(school['performance_2022']);
              school['performance_2021'] = roundToTwoDecimalPlaces(school['performance_2021']);
              
              return school;
            }).toList();
            _isLoading = false;
          });
        } else {
          _showErrorDialog('Unexpected response format');
        }
      } else {
        _showErrorDialog('Failed to fetch recommended schools: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching recommended schools: $e');
    }
  }

  void _showErrorDialog(String message) {
    setState(() {
      _isLoading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Schools'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _recommendedSchools.length,
                    itemBuilder: (context, index) {
                      final school = _recommendedSchools[index];
                      final overallPerformance = school['performance'];
                      final performance2023 = school['performance_2023'];
                      final performance2022 = school['performance_2022'];
                      final performance2021 = school['performance_2021'];

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${school['School']}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text('Overall Performance: ${overallPerformance.toStringAsFixed(2)}'),
                              Text('Performance Grade: ${school['performance_grade']}'),
                              Text('Performance 2023: ${performance2023.toStringAsFixed(2)}'),
                              Text('Performance Grade 2023: ${school['performance_grade_2023']}'),
                              Text('Performance 2022: ${performance2022.toStringAsFixed(2)}'),
                              Text('Performance Grade 2022: ${school['performance_grade_2022']}'),
                              Text('Performance 2021: ${performance2021.toStringAsFixed(2)}'),
                              Text('Performance Grade 2021: ${school['performance_grade_2021']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsScreen(
                          recommendedSchools: _recommendedSchools.cast<Map<String, dynamic>>(),
                        ),
                      ),
                    );
                  },
                  child: const Text('View Statistics'),
                ),
              ],
            ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'statistics.dart';

// class RecommendedSchoolsScreen extends StatefulWidget {
//   final String selectedMunicipal;
//   final String selectedPerformance;
//   final String selectedReligion;
//   final String selectedBoardingDay;
//   final String selectedGender;
//   final String selectedRating;

//   RecommendedSchoolsScreen({
//     required this.selectedMunicipal,
//     required this.selectedPerformance,
//     required this.selectedReligion,
//     required this.selectedBoardingDay,
//     required this.selectedGender,
//     required this.selectedRating,
//   });

//   @override
//   _RecommendedSchoolsScreenState createState() => _RecommendedSchoolsScreenState();
// }

// class _RecommendedSchoolsScreenState extends State<RecommendedSchoolsScreen> {
//   List<dynamic> _recommendedSchools = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRecommendedSchools();
//   }

//   Future<void> _fetchRecommendedSchools() async {
//     final url = 'http://10.0.2.2:5000/school'; // Your Flask server URL

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'performance': widget.selectedPerformance,
//           'location': widget.selectedMunicipal,
//           'religion': widget.selectedReligion,
//           'stars': widget.selectedRating,
//           'gender': widget.selectedGender,
//           'boarding/day': widget.selectedBoardingDay,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);

//         // Log the response to see its content
//         print('Response data: $responseData');

//         if (responseData is List) {
//           setState(() {
//             // Round the overall performance to 2 decimal places
//             _recommendedSchools = responseData.map((school) {
//               if (school['performance'] != null) {
//                 school['performance'] = double.parse(school['performance'].toStringAsFixed(2));
//               }
//               return school;
//             }).toList();
//             _isLoading = false;
//           });
//         } else {
//           _showErrorDialog('Unexpected response format');
//         }
//       } else {
//         _showErrorDialog('Failed to fetch recommended schools: ${response.statusCode}');
//       }
//     } catch (e) {
//       _showErrorDialog('An error occurred while fetching recommended schools: $e');
//     }
//   }

//   void _showErrorDialog(String message) {
//     setState(() {
//       _isLoading = false;
//     });
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Recommended Schools'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _recommendedSchools.length,
//                     itemBuilder: (context, index) {
//                       final school = _recommendedSchools[index];
//                       final overallPerformance = school['performance'] != null
//                           ? (school['performance'] is double
//                               ? school['performance']
//                               : double.tryParse(school['performance'].toString())) ?? 0.0
//                           : 0.0;

//                       return Card(
//                         margin: EdgeInsets.all(8.0),
//                         child: Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${index + 1}. ${school['School']}',
//                                 style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8.0),
//                               Text('Overall Performance: ${overallPerformance.toStringAsFixed(2)}'),
//                               Text('Performance Grade: ${school['performance_grade']}'),
//                               Text('Performance 2023: ${school['performance_2023']}'),
//                               Text('Performance Grade 2023: ${school['performance_grade_2023']}'),
//                               Text('Performance 2022: ${school['performance_2022']}'),
//                               Text('Performance Grade 2022: ${school['performance_grade_2022']}'),
//                               Text('Performance 2021: ${school['performance_2021']}'),
//                               Text('Performance Grade 2021: ${school['performance_grade_2021']}'),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StatisticsScreen(
//                           recommendedSchools: _recommendedSchools.cast<Map<String, dynamic>>(),
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text('View Statistics'),
//                 ),
//               ],
//             ),
//     );
//   }
// }
