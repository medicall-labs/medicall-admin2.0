import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/spacing.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Widgets/back_button.dart';
import 'package:provider/provider.dart';

class ShowAppointment extends StatefulWidget {
  final String heading;

  ShowAppointment({super.key, required this.heading});

  @override
  State<ShowAppointment> createState() => _ShowAppointmentState();
}

class _ShowAppointmentState extends State<ShowAppointment> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> appointmentList = [];
  bool isLoading = false;
  bool hasMore = true;
  var baseUrl = AppUrl.baseUrl;
  late int eventId;
  bool search = false;
  String searchApi = '';

  TextEditingController searchController = TextEditingController();
  TextEditingController scheduledDateController = TextEditingController();

  String? appointmentStatus;
  DateTime? scheduledAt;
  String? sortDirection;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localDataProvider =
          Provider.of<LocalDataProvider>(context, listen: false);
      setState(() {
        eventId = localDataProvider.eventId;
      });
      _loadAppointments(null);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      var nextCursor = GetStorage().read("AppointmentData");
      if (nextCursor != null &&
          nextCursor['paginate_data']['next_cursor'] != null) {
        _loadAppointments(nextCursor['paginate_data']['next_cursor']);
      }
    }
  }

  Future<void> _loadAppointments(nextCursor) async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    var result;

    if (widget.heading == 'Appointment') {
      String query =
          '$baseUrl/admin/appointments?event_id=$eventId&cursor=$nextCursor';

      if (searchController.text.isNotEmpty) {
        query += '&search=${searchController.text}';
      }
      if (appointmentStatus != null) {
        query += '&appointment_status=$appointmentStatus';
      }
      if (scheduledAt != null) {
        query +=
            '&scheduled_at=${scheduledAt!.toLocal().toString().split(' ')[0]}';
      }
      if (sortDirection != null) {
        query += '&sort_direction=$sortDirection';
      }

      result = await RemoteService().getDataFromApi(query);
    } else {
      result = await RemoteService().getDataFromApi(
          '$baseUrl/admin/appointments?event_id=$eventId&appointment_status=${widget.heading}&cursor=$nextCursor');
    }

    GetStorage().write("AppointmentData", result);

    if (result is Map<String, dynamic> && result['appointments'] != null) {
      setState(() {
        appointmentList.addAll(result['appointments']);
        hasMore = result['appointments'].length > 0;
        isLoading = false;
      });
    } else if (result == 'Timeout') {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  void _removeFilter() {
    setState(() {
      searchController.clear();
      scheduledDateController.clear();

      appointmentStatus = null;
      scheduledAt = null;
      sortDirection = null;

      isSearching = false;
      appointmentList = [];
      _loadAppointments(null);
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select your filter options',
                style: AppTextStyles.label2,
              ),
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: 'Search'),
              ),
              DropdownButtonFormField<String>(
                value: appointmentStatus,
                decoration: InputDecoration(labelText: 'Appointment Status'),
                items: [
                  'scheduled',
                  'rescheduled',
                  'completed',
                  'cancelled',
                  'no-show'
                ]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    appointmentStatus = value;
                  });
                },
              ),
              TextField(
                controller: scheduledDateController, // Set the controller
                decoration: InputDecoration(
                  labelText: 'Scheduled At',
                  hintText: scheduledAt != null
                      ? '${scheduledAt!.toLocal()}'.split(' ')[0]
                      : 'Select a date',
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: scheduledAt ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      scheduledAt = picked;
                      scheduledDateController.text = '${scheduledAt!.toLocal()}'
                          .split(' ')[0]; // Update the controller text
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: sortDirection,
                decoration: InputDecoration(labelText: 'Sort Direction'),
                items: ['Ascending', 'Descending']
                    .map((direction) => DropdownMenuItem(
                          value: direction,
                          child: Text(direction),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    if (value == 'Ascending') {
                      sortDirection = 'asc';
                    } else if (value == 'Descending') {
                      sortDirection = 'desc';
                    }
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilter();
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(AppColor.secondary),
                ),
                child: Text(
                  'Apply Filter',
                  style: AppTextStyles.text5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilter() {
    setState(() {
      isSearching = true;
      appointmentList = [];
      _loadAppointments(null);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    scheduledDateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String eventTitle = Provider.of<LocalDataProvider>(context).eventTitle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.secondary,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: NavigationBack(),
        ),
        title: Text(
          widget.heading.toString().toUpperCase(),
          style: AppTextStyles.header1,
        ),
      ),
      backgroundColor: AppColor.bgColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eventTitle,
                    style: AppTextStyles.header2,
                  ),
                  if (widget.heading == 'Appointment')
                    IconButton(
                      onPressed: isSearching ? _removeFilter : _showFilterModal,
                      icon: isSearching
                          ? Icon(Icons.filter_alt_off_rounded)
                          : Icon(Icons.filter_alt_rounded),
                    ),
                ],
              ),
            ),
            appointmentList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointmentList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: AppColor.bgColor),
                          child: ExpansionTile(
                            iconColor: AppColor.grey,
                            textColor: AppColor.primary,
                            title: Row(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Exhibitor name :',
                                        style: TextStyle(
                                            fontSize: 14, color: AppColor.grey),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: Text(
                                          '${appointmentList[index]['exhibitor_name']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        'Visitor name :',
                                        style: TextStyle(
                                            fontSize: 14, color: AppColor.grey),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: Text(
                                          '${appointmentList[index]['visitor_name']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ]),
                            childrenPadding: const EdgeInsets.only(left: 14),
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Designation :',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        '${appointmentList[index]['designation']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Organization :',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                        '${appointmentList[index]['organization']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Products :',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(
                                        '${appointmentList[index]['products']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Scheduled at :',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                        '${appointmentList[index]['scheduled_at']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Updated at :',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(
                                        '${appointmentList[index]['updated_at']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            "Company: ${appointmentList[index]['company']}, Contact person: ${appointmentList[index]['contact_person']}, Contact No: ${appointmentList[index]['contact_no']},Stall No: ${appointmentList[index]['stall_no']}, Stall space: ${appointmentList[index]['stall_space']}, Square space: ${appointmentList[index]['square_space']}, Email: ${appointmentList[index]['email']}, Company Phone No: ${appointmentList[index]['phone_no']}, Address: ${appointmentList[index]['address']}, Products: ${appointmentList[index]['products']}"));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        content:
                                            Text('Exhibitor Details Copied'),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              AppColor.secondary),
                                      minimumSize:
                                          WidgetStateProperty.all<Size>(
                                              Size(120, 25))),
                                  child: const Text(
                                    'Add to Clipboard',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : !isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No exhibitors found')),
                      )
                    : Container(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!hasMore && appointmentList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No more exhibitors')),
              ),
          ],
        ),
      ),
    );
  }
}
