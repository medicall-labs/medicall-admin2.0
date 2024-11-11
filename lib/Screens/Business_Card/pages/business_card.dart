import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../pages/scan_page.dart';
import '../providers/contact_provider.dart';

class BusinessCard extends StatefulWidget {
  const BusinessCard({super.key});

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  @override
  void didChangeDependencies() {
    Provider.of<ContactProvider>(context, listen: false).getAllContacts();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Get.to(ScanPage());
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          backgroundColor: Colors.blue[100],
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          currentIndex: selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'All'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorite')
          ],
        ),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) => ListView.builder(
          itemCount: provider.contactList.length,
          itemBuilder: (context, index) {
            final contact = provider.contactList[index];
            return ListTile(
              title: Text(contact.name),
              subtitle: Text(contact.mobile),
              trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(contact.favorite
                      ? Icons.favorite
                      : Icons.favorite_border)),
            );
          },
        ),
      ),
    );
  }
}
