import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(const AttendanceApp());

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: const Color(0xffd81b60), // Pink Berry
        fontFamily: 'Roboto'
      ),
      home: const LoginPage(),
    );
  }
}

// --- DATA MODELS ---
class Student {
  String name, regNo, currentStatus;
  dynamic image; 
  bool isAsset; // True for original 3 students, False for new ones
  List<String> history;
  Student(this.name, this.regNo, this.image, {this.currentStatus = "Unmarked", required this.history, this.isAsset = false});

  double get percentage {
    if (history.isEmpty) return 0.0;
    int present = history.where((e) => e == "P").length;
    return (present / history.length) * 100;
  }
}

class LeaveRequest {
  String studentName, image, type, date, status;
  LeaveRequest(this.studentName, this.image, this.type, this.date, this.status);
}

// --- GLOBAL DATA ---
List<Student> students = [
  Student("Ali", "REG-001", "assets/images/ali.jpeg", isAsset: true, history: ["P", "P", "A", "P", "P"]),
  Student("Sara", "REG-002", "assets/images/sara.jpeg", isAsset: true, history: ["P", "A", "P", "P", "A"]),
  Student("Ahmed", "REG-003", "assets/images/ahmed.jpeg", isAsset: true, history: ["A", "P", "A", "P", "P"]),
];

List<LeaveRequest> allLeaves = [
  LeaveRequest("Ali", "assets/images/ali.jpeg", "Sick Leave", "2024-05-10", "Pending"),
  LeaveRequest("Sara", "assets/images/sara.jpeg", "Family Event", "2024-05-12", "Approved"),
];

// --- LOGIN SCREEN ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffad1457), Color(0xfff06292)], // Berry to Pink Rose
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/app.json', height: 200),
            const Text("Smart Attendance", 
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
            _roleBtn(context, "Admin Portal", Icons.admin_panel_settings, const AdminDashboard()),
            const SizedBox(height: 15),
            _roleBtn(context, "Student Portal", Icons.face, const StudentDashboard()),
          ],
        ),
      ),
    );
  }
  Widget _roleBtn(context, t, i, p) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(260, 60), 
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      foregroundColor: const Color(0xffad1457),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
    ),
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => p)),
    icon: Icon(i), label: Text(t),
  );
}

// --- ADMIN DASHBOARD ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _showAddStudentSheet() {
    String name = ""; String id = "";
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enroll Student", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffad1457))),
            TextField(onChanged: (v) => name = v, decoration: const InputDecoration(labelText: "Name")),
            TextField(onChanged: (v) => id = v, decoration: const InputDecoration(labelText: "Reg ID")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff06292)),
              onPressed: () {
                if(name.isNotEmpty && id.isNotEmpty) {
                  setState(() => students.add(Student(name, id, Icons.face_retouching_natural, isAsset: false, history: [])));
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Student", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel"), backgroundColor: const Color(0xffad1457), foregroundColor: Colors.white),
      body: Container(
        color: const Color(0xfffce4ec),
        child: GridView.count(
          padding: const EdgeInsets.all(20), crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
          children: [
            _menuCard(context, "Attendance", Icons.fact_check, const AttendancePage()),
            _menuCard(context, "Leaves", Icons.mail_outline, const ManageLeavesPage()),
            _menuCard(context, "Stats", Icons.analytics, const StatsPage()),
            GestureDetector(onTap: _showAddStudentSheet, child: _menuCardUI("Add Student", Icons.person_add)),
          ],
        ),
      ),
    );
  }
  Widget _menuCard(context, t, i, p) => GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => p)), child: _menuCardUI(t, i));
  Widget _menuCardUI(t, i) => Container(
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xffad1457), Color(0xfff06292)]), borderRadius: BorderRadius.circular(20)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: Colors.white, size: 40), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
  );
}

// --- ATTENDANCE PAGE (WITH DISMISSIBLE) ---
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Sheet")),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, i) {
          final s = students[i];
          return Dismissible(
            key: Key(s.regNo),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (dir) => setState(() => students.removeAt(i)),
            child: Card(
              color: s.currentStatus == "Present" ? Colors.green.shade50 : (s.currentStatus == "Absent" ? Colors.red.shade50 : Colors.white),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: s.isAsset ? AssetImage(s.image as String) : null,
                  child: s.isAsset ? null : Icon(s.image as IconData, color: Colors.pink),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ID: ${s.regNo} | ${s.currentStatus}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => setState(() => s.currentStatus = "Present")),
                    IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => setState(() => s.currentStatus = "Absent")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- MANAGE LEAVES ---
class ManageLeavesPage extends StatefulWidget {
  const ManageLeavesPage({super.key});
  @override
  State<ManageLeavesPage> createState() => _ManageLeavesPageState();
}

class _ManageLeavesPageState extends State<ManageLeavesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text("Leaves"), bottom: const TabBar(tabs: [Tab(text: "Pending"), Tab(text: "Approved"), Tab(text: "Canceled")])),
        body: TabBarView(children: [ _view("Pending"), _view("Approved"), _view("Canceled") ]),
      ),
    );
  }
  Widget _view(String f) {
    final list = allLeaves.where((l) => l.status == f).toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) => Card(
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(list[i].studentName), subtitle: Text(list[i].type)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _btn(list[i], "Approved", Colors.green), _btn(list[i], "Pending", Colors.orange), _btn(list[i], "Canceled", Colors.red),
          ]),
        ]),
      ),
    );
  }
  Widget _btn(req, stat, col) => TextButton(onPressed: () => setState(() => req.status = stat), child: Text(stat, style: TextStyle(color: col)));
}

// --- STATS PAGE ---
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    double avg = students.isEmpty ? 0 : students.map((s) => s.percentage).reduce((a, b) => a + b) / students.length;
    return Scaffold(
      appBar: AppBar(title: const Text("Performance")),
      body: Column(
        children: [
          Lottie.asset('assets/animations/app.json', height: 120),
          _tile("Total Students", "${students.length}", Icons.group, Colors.blue),
          _tile("Class Average", "${avg.toStringAsFixed(1)}%", Icons.analytics, Colors.green),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(students[i].name),
                trailing: Text("${students[i].percentage.toStringAsFixed(1)}%"),
                subtitle: LinearProgressIndicator(value: students[i].percentage / 100, color: Colors.pink),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _tile(t, v, i, c) => Card(child: ListTile(leading: Icon(i, color: c), title: Text(t), trailing: Text(v, style: const TextStyle(fontWeight: FontWeight.bold))));
}

// --- STUDENT PORTAL (CALENDAR + PERSISTENT IMAGES) ---
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    if(students.isEmpty) return const Scaffold(body: Center(child: Text("Empty")));
    final user = students[1]; // Sara for demo
    return Scaffold(
      appBar: AppBar(title: const Text("My Portal")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: user.isAsset ? AssetImage(user.image as String) : null,
              child: user.isAsset ? null : Icon(user.image as IconData, size: 50, color: Colors.pink),
            ),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xffad1457), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat("Attendance", "${user.percentage.toStringAsFixed(1)}%"),
                _stat("Status", user.percentage >= 75 ? "SAFE" : "LOW"),
              ]),
            ),
            const Text("Monthly Record", style: TextStyle(fontWeight: FontWeight.bold)),
            GridView.builder(
              padding: const EdgeInsets.all(20), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemCount: 28,
              itemBuilder: (context, index) {
                bool hasData = index < user.history.length;
                bool isP = hasData && user.history[index] == "P";
                return Container(
                  decoration: BoxDecoration(
                    color: hasData ? (isP ? Colors.green.shade200 : Colors.red.shade200) : Colors.white,
                    borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Center(child: Text("${index + 1}", style: const TextStyle(fontSize: 10))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _stat(l, v) => Column(children: [Text(l, style: const TextStyle(color: Colors.white70)), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]);
}