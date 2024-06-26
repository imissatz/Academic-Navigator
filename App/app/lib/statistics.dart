import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class StatisticsScreen extends StatefulWidget {
  final List<dynamic> recommendedSchools;

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

  Future<void> _loadCSVData(
      String path, List<Map<String, dynamic>> dataList) async {
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
        title: const Text('Subject GPA Statistics'),
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

      if (schoolData2023.isNotEmpty) {
        tables.add(
          _buildSchoolYearTable(schoolName, schoolData2023, 2023),
        );
      }
      if (schoolData2022.isNotEmpty) {
        tables.add(
          _buildSchoolYearTable(schoolName, schoolData2022, 2022),
        );
      }
      if (schoolData2021.isNotEmpty) {
        tables.add(
          _buildSchoolYearTable(schoolName, schoolData2021, 2021),
        );
      }
    }

    return tables;
  }

  Widget _buildSchoolYearTable(
      String schoolName, List<Map<String, dynamic>> schoolData, int year) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Text(
              '$schoolName - $year',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _buildColumns(),
                rows: _generateTableRows(schoolData),
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
      DataColumn(label: Text('GPA')),
      DataColumn(label: Text('Grade')),
      DataColumn(label: Text('Year')),
    ];
  }

  List<DataRow> _generateTableRows(List<Map<String, dynamic>> schoolData) {
    List<DataRow> rows = [];

    for (var row in schoolData) {
      for (String subject in row.keys) {
        if (subject != 'School' && subject != 'Year') {
          try {
            double gpa = double.parse(row[subject].toString());
            rows.add(DataRow(cells: [
              DataCell(Text(subject)),
              DataCell(Text(gpa.toStringAsFixed(2))),
              DataCell(Text(_gradeGpa(gpa))),
              DataCell(Text(row['Year'].toString())),
            ]));
          } catch (e) {
            // Skip invalid GPA values
          }
        }
      }
    }

    return rows;
  }
}

void main() {
  runApp(MaterialApp(
    home: StatisticsScreen(
      recommendedSchools: [
        {'School': 'School A'},
        {'School': 'School B'},
        // Add more schools as needed
      ],
    ),
  ));
}








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:csv/csv.dart';

// class StatisticsScreen extends StatefulWidget {
//   final List<dynamic> recommendedSchools;

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

//   Future<void> _loadCSVData(
//       String path, List<Map<String, dynamic>> dataList) async {
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
//         title: const Text('Subject GPA Statistics'),
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

//       if (schoolData2023.isNotEmpty) {
//         tables.add(
//           _buildSchoolYearTable(schoolName, schoolData2023, 2023),
//         );
//       }
//       if (schoolData2022.isNotEmpty) {
//         tables.add(
//           _buildSchoolYearTable(schoolName, schoolData2022, 2022),
//         );
//       }
//       if (schoolData2021.isNotEmpty) {
//         tables.add(
//           _buildSchoolYearTable(schoolName, schoolData2021, 2021),
//         );
//       }
//     }

//     return tables;
//   }

//   Widget _buildSchoolYearTable(
//       String schoolName, List<Map<String, dynamic>> schoolData, int year) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Card(
//         child: Column(
//           children: [
//             Text(
//               '$schoolName - $year',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: _buildColumns(),
//                 rows: _generateTableRows(schoolData),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<DataColumn> _buildColumns() {
//     return [
//       DataColumn(label: Text('School')),
//       DataColumn(label: Text('Subject')),
//       DataColumn(label: Text('GPA')),
//       DataColumn(label: Text('Grade')),
//       DataColumn(label: Text('Year')),
//     ];
//   }

//   List<DataRow> _generateTableRows(List<Map<String, dynamic>> schoolData) {
//     List<DataRow> rows = [];

//     for (var row in schoolData) {
//       for (String subject in row.keys) {
//         if (subject != 'School' && subject != 'Year') {
//           try {
//             double gpa = double.parse(row[subject].toString());
//             rows.add(DataRow(cells: [
//               // DataCell(Text(row['School'].toString())),
//               DataCell(Text(subject)),
//               DataCell(Text(gpa.toStringAsFixed(2))),
//               DataCell(Text(_gradeGpa(gpa))),
//               DataCell(Text(row['Year'].toString())),
//             ]));
//           } catch (e) {
//             // Skip invalid GPA values
//           }
//         }
//       }
//     }

//     return rows;
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: StatisticsScreen(
//       recommendedSchools: [
//         {'School': 'School A'},
//         {'School': 'School B'},
//         // Add more schools as needed
//       ],
//     ),
//   ));
// }

