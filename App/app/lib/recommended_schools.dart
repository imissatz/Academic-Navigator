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
  _RecommendedSchoolsScreenState createState() =>
      _RecommendedSchoolsScreenState();
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
    final url = 'http://127.0.0.1:5000/school'; // Your Flask server URL

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
            _recommendedSchools = responseData;
            _isLoading = false;
          });
        } else {
          _showErrorDialog('Unexpected response format');
        }
      } else {
        _showErrorDialog(
            'Failed to fetch recommended schools: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(
          'An error occurred while fetching recommended schools: $e');
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
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${_recommendedSchools[index]['School']}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              // Text(
                              //     'School Name: ${_recommendedSchools[index]['School']}'),
                              Text(
                                  'Overall Performance: ${_recommendedSchools[index]['performance']}'),
                              Text(
                                  'Performance Grade: ${_recommendedSchools[index]['performance_grade']}'),
                              Text(
                                  'Performance 2023: ${_recommendedSchools[index]['performance_2023']}'),
                              Text(
                                  'Performance Grade: ${_recommendedSchools[index]['performance_grade_2023']}'),
                              Text(
                                  'Performance 2022: ${_recommendedSchools[index]['performance_2022']}'),
                              Text(
                                  'Performance Grade: ${_recommendedSchools[index]['performance_grade_2022']}'),
                              Text(
                                  'Performance 2021: ${_recommendedSchools[index]['performance_2021']}'),
                              Text(
                                  'Performance Grade: ${_recommendedSchools[index]['performance_grade_2021']}'),
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
                          recommendedSchools: _recommendedSchools,
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
