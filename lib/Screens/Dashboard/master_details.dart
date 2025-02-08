import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../Master/exhibitor.dart';
import '../Master/visitor.dart';

class MasterDetails extends StatefulWidget {
  const MasterDetails({super.key});

  @override
  _MasterDetailsState createState() => _MasterDetailsState();
}

class _MasterDetailsState extends State<MasterDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  var storedData = GetStorage().read("local_store");

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCard(
              "Exhibitors",
              Icons.business,
              Colors.blue,
              ExhibitorMaster(isMasters: true),
              storedData['data']['permissions']['can_view_exhibitor'],
            ),
            _buildCard(
              "Visitors",
              Icons.people,
              Colors.green,
              VisitorMaster(isMasters: true),
              storedData['data']['permissions']['can_view_visitor'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, Widget page,
      bool hasPermission) {
    return GestureDetector(
      onTap: hasPermission
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Access Denied"),
                  content:
                      Text("You do not have permission to view $title master."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
      child: Card(
        elevation: 5,
        color: hasPermission ? color : Colors.grey,
        child: SizedBox(
          width: 300,
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              AppSpaces.horizontalSpace10,
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
