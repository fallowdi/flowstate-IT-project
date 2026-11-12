import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String studentName = 'Maxiwell';
  bool focusMode = false;

  final List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'Indonesian',
    'History',
    'Geography',
    'Biology',
    'Physics',
    'Chemistry',
    'Computer Science',
    'Art',
    'Other',
  ];

final List assignments = [];

final List schedule = [];

  final Map<String, bool> meals = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ---------------- PERSISTENCE (LOAD & SAVE) ----------------

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      studentName = prefs.getString('studentName') ?? 'Maxiwell';
      focusMode = prefs.getBool('focusMode') ?? false;

      // Load meals
      final savedMeals = prefs.getString('meals');
      if (savedMeals != null) {
        final Map<String, dynamic> decodedMeals = jsonDecode(savedMeals);
        decodedMeals.forEach((key, value) {
          if (meals.containsKey(key)) {
            meals[key] = value as bool;
          }
        });
      }

      // Load assignments
      final savedAssignments = prefs.getString('assignments');
      if (savedAssignments != null) {
        final List<dynamic> decodedList = jsonDecode(savedAssignments);
        assignments.clear();
        for (var item in decodedList) {
          assignments.add({
            'title': item['title'],
            'subject': item['subject'],
            'date': DateTime.parse(item['date']),
            'done': item['done'],
          });
        }
      }

      // Load schedule
      final savedSchedule = prefs.getString('schedule');
      if (savedSchedule != null) {
        final List<dynamic> decodedList = jsonDecode(savedSchedule);
        schedule.clear();
        for (var item in decodedList) {
          schedule.add({
            'title': item['title'],
            'time': TimeOfDay(
              hour: item['hour'],
              minute: item['minute'],
            ),
          });
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('studentName', studentName);
    await prefs.setBool('focusMode', focusMode);
    await prefs.setString('meals', jsonEncode(meals));

    // Convert DateTime to ISO8601 String before encoding
    final encodedAssignments = assignments.map((a) {
      return {
        'title': a['title'],
        'subject': a['subject'],
        'date': (a['date'] as DateTime).toIso8601String(),
        'done': a['done'],
      };
    }).toList();
    await prefs.setString('assignments', jsonEncode(encodedAssignments));

    // Convert TimeOfDay to hour & minute ints before encoding
    final encodedSchedule = schedule.map((s) {
      final time = s['time'] as TimeOfDay;
      return {
        'title': s['title'],
        'hour': time.hour,
        'minute': time.minute,
      };
    }).toList();
    await prefs.setString('schedule', jsonEncode(encodedSchedule));
  }

  // ---------------- MAIN SCREEN ----------------

  @override
  Widget build(BuildContext context) {
    final completed = assignments.where((a) => a['done'] == true).length;

    final assignmentProgress =
        assignments.isEmpty ? 0.0 : completed / assignments.length;

    final mealProgress =
        meals.values.where((value) => value).length / meals.length;

    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171321),
              Color(0xFF09090D),
              Color(0xFF000000),
              Color(0xFF100D18),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP BAR
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFB69AFF),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'FlowState',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: editProfile,
                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // GREETING
                Text(
                  'Hello, $studentName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Let’s make today a balanced one.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                // DAILY OVERVIEW
                const Text(
                  'Daily Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                panel(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      progressRing(
                        title: 'Sleep',
                        value: 7.5 / 9,
                        detail: '7.5 / 9 hrs',
                        color: const Color(0xFF9B8AFF),
                      ),
                      progressRing(
                        title: 'Meals',
                        value: mealProgress,
                        detail: '${meals.values.where((v) => v).length} / 3',
                        color: const Color(0xFF72D6B0),
                      ),
                      progressRing(
                        title: 'Tasks',
                        value: assignmentProgress,
                        detail: '$completed / ${assignments.length}',
                        color: const Color(0xFFFFC477),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // HEALTH
                const Text(
                  'Your Wellbeing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            color: Color(0xFFB69AFF),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Sleep',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '7h 30m',
                            style: TextStyle(
                              color: Color(0xFFB69AFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const LinearProgressIndicator(
                          value: 7.5 / 9,
                          minHeight: 9,
                          backgroundColor: Color(0xFF34313F),
                          valueColor: AlwaysStoppedAnimation(
                            Color(0xFF9B8AFF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Your sleep goal is 9 hours.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Divider(color: Colors.white12),

                      const SizedBox(height: 15),

                      const Row(
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            color: Color(0xFF72D6B0),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Screen Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '1h 12m',
                            style: TextStyle(
                              color: Color(0xFF72D6B0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'A little time away from your screen can help you recharge.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // MEALS
                const Text(
                  'Nutrition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                panel(
                  child: Column(
                    children: meals.keys.map((meal) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          meal,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          meals[meal]!
                              ? 'Completed'
                              : 'Mark when you have eaten',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        value: meals[meal],
                        activeColor: const Color(0xFF72D6B0),
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            meals[meal] = value ?? false;
                          });
                          _saveData();
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                // ASSIGNMENTS
                Row(
                  children: [
                    const Text(
                      'Assignments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    addButton(
                      label: 'Add',
                      onPressed: addAssignment,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                panel(
                  child: assignments.isEmpty
                      ? emptyMessage(
                          Icons.assignment_outlined,
                          'No assignments yet.',
                          'Add an assignment to get started.',
                        )
                      : Column(
                          children: assignments.map((assignment) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Checkbox(
                                value: assignment['done'],
                                activeColor: const Color(0xFF72D6B0),
                                onChanged: (value) {
                                  setState(() {
                                    assignment['done'] = value ?? false;
                                  });
                                  _saveData();
                                },
                              ),
                              title: Text(
                                assignment['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: assignment['done']
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                '${assignment['subject']} • Due ${formatDate(assignment['date'])}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    assignments.remove(assignment);
                                  });
                                  _saveData();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 28),

                // SCHEDULE
                Row(
                  children: [
                    const Text(
                      'Daily Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    addButton(
                      label: 'Add',
                      onPressed: addSchedule,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                panel(
                  child: schedule.isEmpty
                      ? emptyMessage(
                          Icons.calendar_month_outlined,
                          'Your schedule is empty.',
                          'Add activities to plan your day.',
                        )
                      : Column(
                          children: schedule.map((item) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.access_time,
                                color: Color(0xFFB69AFF),
                              ),
                              title: Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                formatTime(item['time']),
                                style: const TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    schedule.remove(item);
                                  });
                                  _saveData();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 28),

                // FOCUS MODE
                panel(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Focus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Take a moment to focus on yourself.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: focusMode,
                        activeThumbColor: const Color(0xFFB69AFF),
                        onChanged: (value) {
                          setState(() {
                            focusMode = value;
                          });
                          _saveData();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                focusMode
                                    ? 'Focus Mode activated ✨'
                                    : 'Focus Mode turned off',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF19191F).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget progressRing({
    required String title,
    required double value,
    required String detail,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 65,
          height: 65,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 7,
            backgroundColor: const Color(0xFF34313F),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget addButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB69AFF),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget emptyMessage(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Icon(icon, color: Colors.white38, size: 35),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PROFILE ----------------

  void editProfile() {
    final controller = TextEditingController(text: studentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19191F),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Your name',
              labelStyle: TextStyle(color: Colors.white60),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    studentName = controller.text.trim();
                  });
                  _saveData();
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFB69AFF)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- ADD ASSIGNMENT ----------------

  void addAssignment() {
    final titleController = TextEditingController();
    String selectedSubject = subjects.first;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF19191F),
              title: const Text(
                'New Assignment',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Assignment title',
                        labelStyle: TextStyle(color: Colors.white60),
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: selectedSubject,
                      dropdownColor: const Color(0xFF292633),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(color: Colors.white60),
                      ),
                      items: subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            selectedSubject = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Due date',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              updateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            formatDate(selectedDate),
                            style: const TextStyle(
                              color: Color(0xFFB69AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      assignments.add({
                        'title': titleController.text.trim(),
                        'subject': selectedSubject,
                        'date': selectedDate,
                        'done': false,
                      });
                    });
                    _saveData();

                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Add Assignment',
                    style: TextStyle(color: Color(0xFFB69AFF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------- ADD SCHEDULE ----------------

  void addSchedule() {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF19191F),
              title: const Text(
                'Add to Schedule',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Activity name',
                      labelStyle: TextStyle(color: Colors.white60),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Time',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (picked != null) {
                            updateDialog(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            color: Color(0xFFB69AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      schedule.add({
                        'title': titleController.text.trim(),
                        'time': selectedTime,
                      });

                      schedule.sort((a, b) {
                        final first = a['time'] as TimeOfDay;
                        final second = b['time'] as TimeOfDay;

                        final firstMinutes = first.hour * 60 + first.minute;
                        final secondMinutes = second.hour * 60 + second.minute;

                        return firstMinutes.compareTo(secondMinutes);
                      });
                    });
                    _saveData();

                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Add Activity',
                    style: TextStyle(color: Color(0xFFB69AFF)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------- DATE AND TIME FORMATTING ----------------

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }
}
