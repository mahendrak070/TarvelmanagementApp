import 'package:flutter/material.dart';

enum PlanPriority { Low, Medium, High }

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  PlanPriority priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = PlanPriority.Low,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Using soft complementary colors in the theme.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Plans',
      theme: ThemeData(
        primaryColor: Colors.lightBlue[200],
        scaffoldBackgroundColor: Color(0xFFFFF8E1), // soft cream
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[200],
          titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  // Calendar parameters for the current month.
  late int currentYear;
  late int currentMonth;
  late int daysInMonth;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;
    // Get the last day of the current month.
    daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
  }

  // Add a new plan and sort by priority (High first).
  void _addPlan(Plan plan) {
    setState(() {
      plans.add(plan);
      _sortPlans();
    });
  }

  // Update an existing plan.
  void _updatePlan(int index, Plan updatedPlan) {
    setState(() {
      plans[index] = updatedPlan;
      _sortPlans();
    });
  }

  // Remove a plan from the list.
  void _removePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  // Toggle plan's completed status.
  void _toggleComplete(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  // Sort plans based on priority: High > Medium > Low.
  void _sortPlans() {
    plans.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  // Show the modal for creating or editing a plan.
  Future<void> _showPlanDialog({Plan? plan, int? index}) async {
    String name = plan?.name ?? '';
    String description = plan?.description ?? '';
    DateTime? selectedDate = plan?.date;
    PlanPriority selectedPriority = plan?.priority ?? PlanPriority.Low;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white70,
          title: Text(plan == null ? 'Create New Plan' : 'Edit Plan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Plan Name Input.
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      labelText: 'Plan Name',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter plan name' : null,
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  // Plan Description Input.
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                  SizedBox(height: 10),
                  // Date Selector Row.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? selectedDate!.toLocal().toString().split(' ')[0]
                              : 'Select Date',
                          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.blueGrey),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Priority Dropdown.
                  DropdownButtonFormField<PlanPriority>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                    items: PlanPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toString().split('.').last,
                            style: TextStyle(color: Colors.blueGrey)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedPriority = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[200]),
              child: Text(plan == null ? 'Add Plan' : 'Update Plan'),
              onPressed: () {
                if (formKey.currentState!.validate() && selectedDate != null) {
                  final newPlan = Plan(
                    name: name,
                    description: description,
                    date: selectedDate!,
                    priority: selectedPriority,
                  );
                  if (plan == null) {
                    _addPlan(newPlan);
                  } else if (index != null) {
                    _updatePlan(index, newPlan);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Build an interactive calendar banner.
  Widget _buildCalendarBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: Column(
        children: [
          Text(
            'Calendar - ${_monthName(currentMonth)} $currentYear',
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          // Display the days as a grid.
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              int day = index + 1;
              return DragTarget<Plan>(
                onWillAccept: (data) => true,
                onAccept: (plan) {
                  setState(() {
                    plan.date = DateTime(currentYear, currentMonth, day);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.teal[200],
                      content: Text(
                        'Updated "${plan.name}" to ${DateTime(currentYear, currentMonth, day).toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty ? Colors.teal[200] : Colors.white,
                      border: Border.all(
                        color: candidateData.isNotEmpty ? Colors.blue : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: candidateData.isNotEmpty ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper to convert month number to month name.
  String _monthName(int month) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  // Build method combining calendar banner and plan list.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adoption & Travel Plans'),
      ),
      body: Column(
        children: [
          // Calendar banner section.
          _buildCalendarBanner(),
          Divider(color: Colors.blueGrey),
          // Plan list section.
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.lightGreen,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  // Swipe right toggles completion.
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _toggleComplete(index);
                      return false;
                    }
                    return false;
                  },
                  child: GestureDetector(
                    onLongPress: () {
                      // Long press to edit plan.
                      _showPlanDialog(plan: plan, index: index);
                    },
                    onDoubleTap: () {
                      // Double tap to delete plan.
                      _removePlan(index);
                    },
                    child: Draggable<Plan>(
                      data: plan,
                      feedback: Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: _buildPlanCard(plan),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: _buildPlanCard(plan),
                        ),
                      ),
                      child: _buildPlanCard(plan),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[200],
        onPressed: () => _showPlanDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  // Build a plan card that is color-coded by status.
  Widget _buildPlanCard(Plan plan) {
    Color cardColor = plan.isCompleted ? Colors.green.shade50 : Colors.white;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: cardColor,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          plan.name,
          style: TextStyle(
            decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        subtitle: Text(
          '${plan.description}\n'
          '${plan.date.toLocal().toString().split(' ')[0]}'
          ' | Priority: ${plan.priority.toString().split('.').last}',
          style: TextStyle(color: Colors.blueGrey.shade600),
        ),
      ),
    );
  }
}
