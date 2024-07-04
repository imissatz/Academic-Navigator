import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'school_pictures.dart'; // Import the new screen

class StatisticsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recommendedSchools;

  StatisticsScreen({required this.recommendedSchools});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _csvData2023 = [];
  List<Map<String, dynamic>> _csvData2022 = [];
  List<Map<String, dynamic>> _csvData2021 = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCSVData();
  }

  Future<void> _loadAllCSVData() async {
    await _loadCSVData('assets/subject_gpa2023.csv', _csvData2023);
    await _loadCSVData('assets/subject_gpa2022.csv', _csvData2022);
    await _loadCSVData('assets/subject_gpa2021.csv', _csvData2021);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCSVData(String path, List<Map<String, dynamic>> dataList) async {
    final data = await rootBundle.loadString(path);
    List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

    List<String> headers = csvTable[0].cast<String>();

    for (var i = 1; i < csvTable.length; i++) {
      Map<String, dynamic> row = {};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = csvTable[i][j];
      }
      dataList.add(row);
    }
  }

  String _gradeGpa(double gpa) {
    if (gpa <= 1.7) {
      return "A (Excellent)";
    } else if (gpa < 2.5) {
      return "B (Very Good)";
    } else if (gpa < 3.6) {
      return "C (Good)";
    } else if (gpa < 4.6) {
      return "D (Satisfactory)";
    } else {
      return "F (Fail)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject GPA'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolPicturesScreen(
                    recommendedSchools: widget.recommendedSchools.map((school) {
                      return {
                        ...school,
                        'imageFolderPath': 'assets/pictures/${school['School'].toString().replaceAll(' ', '_').toLowerCase()}'
                      };
                    }).toList().cast<Map<String, dynamic>>(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: _buildTables(),
              ),
            ),
    );
  }

  List<Widget> _buildTables() {
    List<Widget> tables = [];

    for (var school in widget.recommendedSchools) {
      String schoolName = school['School'];
      List<Map<String, dynamic>> schoolData2023 =
          _csvData2023.where((row) => row['School'] == schoolName).toList();
      List<Map<String, dynamic>> schoolData2022 =
          _csvData2022.where((row) => row['School'] == schoolName).toList();
      List<Map<String, dynamic>> schoolData2021 =
          _csvData2021.where((row) => row['School'] == schoolName).toList();

      if (schoolData2023.isNotEmpty ||
          schoolData2022.isNotEmpty ||
          schoolData2021.isNotEmpty) {
        tables.add(
          _buildSchoolTable(schoolName, schoolData2023, schoolData2022, schoolData2021),
        );
      }
    }

    return tables;
  }

  Widget _buildSchoolTable(
      String schoolName,
      List<Map<String, dynamic>> schoolData2023,
      List<Map<String, dynamic>> schoolData2022,
      List<Map<String, dynamic>> schoolData2021) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Text(
              schoolName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _buildColumns(),
                rows: _generateTableRows(
                    schoolData2023, schoolData2022, schoolData2021),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: Text('Subject')),
      DataColumn(label: Text('GPA 2023')),
      DataColumn(label: Text('Grade 2023')),
      DataColumn(label: Text('GPA 2022')),
      DataColumn(label: Text('Grade 2022')),
      DataColumn(label: Text('GPA 2021')),
      DataColumn(label: Text('Grade 2021')),
    ];
  }

  List<DataRow> _generateTableRows(
      List<Map<String, dynamic>> data2023,
      List<Map<String, dynamic>> data2022,
      List<Map<String, dynamic>> data2021) {
    List<DataRow> rows = [];
    Set<String> subjects = {};

    for (var row in data2023) {
      subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
    }
    for (var row in data2022) {
      subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
    }
    for (var row in data2021) {
      subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
    }

    for (var subject in subjects) {
      // Helper function to round and format the GPA values
      String? formatGpa(dynamic value) {
        if (value == null) return null;
        double? parsedValue = double.tryParse(value.toString());
        if (parsedValue == null) return null;
        return parsedValue.toStringAsFixed(2);
      }

      double? gpa2023 = data2023.isNotEmpty
          ? double.tryParse(data2023
                  .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
                  ?.toString() ??
              '0')
          : null;
      double? gpa2022 = data2022.isNotEmpty
          ? double.tryParse(data2022
                  .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
                  ?.toString() ??
              '0')
          : null;
      double? gpa2021 = data2021.isNotEmpty
          ? double.tryParse(data2021
                  .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
                  ?.toString() ??
              '0')
          : null;

      // Skip subjects where all GPA values are null
      if (gpa2023 == null && gpa2022 == null && gpa2021 == null) {
        continue;
      }

      rows.add(
        DataRow(
          cells: [
            DataCell(Text(subject)),
            DataCell(Text(formatGpa(gpa2023) ?? 'N/A')),  // GPA 2023 rounded
            DataCell(Text(_gradeGpa(gpa2023 ?? 0))),
            DataCell(Text(formatGpa(gpa2022) ?? 'N/A')),  // GPA 2022 rounded
            DataCell(Text(_gradeGpa(gpa2022 ?? 0))),
            DataCell(Text(formatGpa(gpa2021) ?? 'N/A')),  // GPA 2021 rounded
            DataCell(Text(_gradeGpa(gpa2021 ?? 0))),
          ],
        ),
      );
    }

    return rows;
  }
}








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:csv/csv.dart';
// import 'school_pictures.dart'; // Import the new screen

// class StatisticsScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> recommendedSchools;

//   StatisticsScreen({required this.recommendedSchools});

//   @override
//   _StatisticsScreenState createState() => _StatisticsScreenState();
// }

// class _StatisticsScreenState extends State<StatisticsScreen> {
//   List<Map<String, dynamic>> _csvData2023 = [];
//   List<Map<String, dynamic>> _csvData2022 = [];
//   List<Map<String, dynamic>> _csvData2021 = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAllCSVData();
//   }

//   Future<void> _loadAllCSVData() async {
//     await _loadCSVData('assets/subject_gpa2023.csv', _csvData2023);
//     await _loadCSVData('assets/subject_gpa2022.csv', _csvData2022);
//     await _loadCSVData('assets/subject_gpa2021.csv', _csvData2021);
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _loadCSVData(String path, List<Map<String, dynamic>> dataList) async {
//     final data = await rootBundle.loadString(path);
//     List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

//     List<String> headers = csvTable[0].cast<String>();

//     for (var i = 1; i < csvTable.length; i++) {
//       Map<String, dynamic> row = {};
//       for (var j = 0; j < headers.length; j++) {
//         row[headers[j]] = csvTable[i][j];
//       }
//       dataList.add(row);
//     }
//   }

//   String _gradeGpa(double gpa) {
//     if (gpa <= 1.7) {
//       return "A (Excellent)";
//     } else if (gpa < 2.5) {
//       return "B (Very Good)";
//     } else if (gpa < 3.6) {
//       return "C (Good)";
//     } else if (gpa < 4.6) {
//       return "D (Satisfactory)";
//     } else {
//       return "F (Fail)";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Subject GPA'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.photo),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SchoolPicturesScreen(
//                     recommendedSchools: widget.recommendedSchools.map((school) {
//                       return {
//                         ...school,
//                         'imageFolderPath': 'assets/pictures/${school['School'].toString().replaceAll(' ', '_').toLowerCase()}'
//                       };
//                     }).toList().cast<Map<String, dynamic>>(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 children: _buildTables(),
//               ),
//             ),
//     );
//   }

//   List<Widget> _buildTables() {
//     List<Widget> tables = [];

//     for (var school in widget.recommendedSchools) {
//       String schoolName = school['School'];
//       List<Map<String, dynamic>> schoolData2023 =
//           _csvData2023.where((row) => row['School'] == schoolName).toList();
//       List<Map<String, dynamic>> schoolData2022 =
//           _csvData2022.where((row) => row['School'] == schoolName).toList();
//       List<Map<String, dynamic>> schoolData2021 =
//           _csvData2021.where((row) => row['School'] == schoolName).toList();

//       if (schoolData2023.isNotEmpty ||
//           schoolData2022.isNotEmpty ||
//           schoolData2021.isNotEmpty) {
//         tables.add(
//           _buildSchoolTable(schoolName, schoolData2023, schoolData2022, schoolData2021),
//         );
//       }
//     }

//     return tables;
//   }

//   Widget _buildSchoolTable(
//       String schoolName,
//       List<Map<String, dynamic>> schoolData2023,
//       List<Map<String, dynamic>> schoolData2022,
//       List<Map<String, dynamic>> schoolData2021) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Card(
//         child: Column(
//           children: [
//             Text(
//               schoolName,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: _buildColumns(),
//                 rows: _generateTableRows(
//                     schoolData2023, schoolData2022, schoolData2021),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<DataColumn> _buildColumns() {
//     return [
//       DataColumn(label: Text('Subject')),
//       DataColumn(label: Text('GPA 2023')),
//       DataColumn(label: Text('Grade 2023')),
//       DataColumn(label: Text('GPA 2022')),
//       DataColumn(label: Text('Grade 2022')),
//       DataColumn(label: Text('GPA 2021')),
//       DataColumn(label: Text('Grade 2021')),
//     ];
//   }

//   List<DataRow> _generateTableRows(
//       List<Map<String, dynamic>> data2023,
//       List<Map<String, dynamic>> data2022,
//       List<Map<String, dynamic>> data2021) {
//     List<DataRow> rows = [];
//     Set<String> subjects = {};

//     for (var row in data2023) {
//       subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
//     }
//     for (var row in data2022) {
//       subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
//     }
//     for (var row in data2021) {
//       subjects.addAll(row.keys.where((key) => key != 'School' && key != 'Year'));
//     }

//     for (var subject in subjects) {
//       // Helper function to round and format the GPA values
//       String? formatGpa(dynamic value) {
//         if (value == null) return null;
//         double? parsedValue = double.tryParse(value.toString());
//         if (parsedValue == null) return null;
//         return parsedValue.toStringAsFixed(2);
//       }

//       double? gpa2023 = data2023.isNotEmpty
//           ? double.tryParse(data2023
//                   .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
//                   ?.toString() ??
//               '0')
//           : null;
//       double? gpa2022 = data2022.isNotEmpty
//           ? double.tryParse(data2022
//                   .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
//                   ?.toString() ??
//               '0')
//           : null;
//       double? gpa2021 = data2021.isNotEmpty
//           ? double.tryParse(data2021
//                   .firstWhere((row) => row.containsKey(subject), orElse: () => {subject: null})[subject]
//                   ?.toString() ??
//               '0')
//           : null;

//       rows.add(
//         DataRow(
//           cells: [
//             DataCell(Text(subject)),
//             DataCell(Text(formatGpa(gpa2023) ?? 'N/A')),  // GPA 2023 rounded
//             DataCell(Text(_gradeGpa(gpa2023 ?? 0))),
//             DataCell(Text(formatGpa(gpa2022) ?? 'N/A')),  // GPA 2022 rounded
//             DataCell(Text(_gradeGpa(gpa2022 ?? 0))),
//             DataCell(Text(formatGpa(gpa2021) ?? 'N/A')),  // GPA 2021 rounded
//             DataCell(Text(_gradeGpa(gpa2021 ?? 0))),
//           ],
//         ),
//       );
//     }

//     return rows;
//   }
// }
