import 'package:flutter/material.dart';

import '../Master/exhibitor.dart';
import '../Master/visitor.dart';

class MasterDetails extends StatefulWidget {
  const MasterDetails({super.key});

  @override
  _MasterDetailsState createState() => _MasterDetailsState();
}

class _MasterDetailsState extends State<MasterDetails> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
            _buildCard("Exhibitors", Icons.business, Colors.blue, ExhibitorMaster(isMasters: true,)),
            _buildCard("Visitors", Icons.people, Colors.green, VisitorMaster(isMasters: true,)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 5,
        color: color,
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
              const SizedBox(width: 10), // Space between icon and text
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

