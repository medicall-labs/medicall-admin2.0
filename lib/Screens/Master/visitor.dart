import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:admin_medicall/Providers/local_data.dart';
import 'package:admin_medicall/Sevices/api_services.dart';
import 'package:admin_medicall/Utils/Constants/api_collection.dart';
import 'package:admin_medicall/Utils/Constants/app_color.dart';
import 'package:admin_medicall/Utils/Constants/styles.dart';
import 'package:admin_medicall/Utils/Widgets/back_button.dart';
import 'package:provider/provider.dart';

class VisitorMaster extends StatefulWidget {
  final bool? isMasters;
  const VisitorMaster({super.key, this.isMasters});

  @override
  State<VisitorMaster> createState() => _VisitorMasterState();
}

class _VisitorMasterState extends State<VisitorMaster> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> visitorList = [];
  bool isLoading = false;
  bool hasMore = true;
  var baseUrl = AppUrl.baseUrl;
  late int eventId;
  bool search = false;
  String searchApi = '';

  // Filter variables
  TextEditingController searchController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  String? participateStatus;
  String? visitorRegId;
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
      _loadVisitors(null);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      var nextCursor = GetStorage().read("VisitorMaster");
      if (nextCursor != null &&
          nextCursor['paginate_data']['next_cursor'] != null) {
        _loadVisitors(nextCursor['paginate_data']['next_cursor']);
      }
    }
  }

  Future<void> _loadVisitors(nextCursor) async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });
    String query = widget.isMasters == true
        ? '$baseUrl/admin/visitors?cursor=$nextCursor'
        : '$baseUrl/admin/visitors?event_id=$eventId&cursor=$nextCursor';

    if (searchController.text.isNotEmpty) {
      query += '&search=${searchController.text}';
    }
    if (selectedType != null) {
      query += '&type=$selectedType';
    }
    if (startDate != null) {
      query += '&start_date=${startDate!.toLocal().toString().split(' ')[0]}';
    }
    if (endDate != null) {
      query += '&end_date=${endDate!.toLocal().toString().split(' ')[0]}';
    }
    if (participateStatus != null) {
      query += '&participate_status=$participateStatus';
    }
    if (visitorRegId != null && visitorRegId!.isNotEmpty) {
      query += '&visitor_reg_id=$visitorRegId';
    }
    if (sortDirection != null) {
      query += '&sort_direction=$sortDirection';
    }

    var result = await RemoteService().getDataFromApi(query);

    GetStorage().write("VisitorMaster", result);

    if (result is Map<String, dynamic> && result['visitors'] != null) {
      setState(() {
        visitorList.addAll(result['visitors']);
        hasMore = result['visitors'].length > 0;
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
      startDateController.clear();
      endDateController.clear();

      selectedType = null;
      startDate = null;
      endDate = null;
      participateStatus = null;
      visitorRegId = null;
      sortDirection = null;

      isSearching = false;
      visitorList = [];
      _loadVisitors(null);
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController, // Set the controller
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        hintText: startDate != null
                            ? '${startDate!.toLocal()}'.split(' ')[0]
                            : 'Select a date',
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            startDateController.text = '${startDate!.toLocal()}'
                                .split(' ')[0]; // Update the controller text
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endDateController, // Set the controller
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        hintText: endDate != null
                            ? '${endDate!.toLocal()}'.split(' ')[0]
                            : 'Select a date',
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                            endDateController.text = '${endDate!.toLocal()}'
                                .split(' ')[0]; // Update the controller text
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: 'Type'),
                items: ['web', 'medicall', 'online', '10t', 'whatsapp']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: participateStatus,
                decoration: InputDecoration(labelText: 'Participate Status'),
                items: ['Visited', 'Not Visited']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    participateStatus = value;
                    if (value == 'Visited') {
                      participateStatus = 'visited';
                    } else if (value == 'Not Visited') {
                      participateStatus = 'not_visited';
                    }
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Visitor Reg ID'),
                onChanged: (value) {
                  setState(() {
                    visitorRegId = value;
                  });
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
      visitorList = [];
      _loadVisitors(null);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    startDateController.dispose();
    endDateController.dispose();
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
          widget.isMasters == true ? 'Visitor Master' : 'Visitors List',
          style: AppTextStyles.header1,
        ),
        actions: [
          widget.isMasters == true
              ? IconButton(
                  onPressed: isSearching ? _removeFilter : _showFilterModal,
                  icon: isSearching
                      ? Icon(
                          Icons.filter_alt_off_rounded,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.filter_alt_rounded,
                          color: Colors.white,
                        ),
                )
              : SizedBox(),
        ],
      ),
      backgroundColor: AppColor.bgColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isMasters != true)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      eventTitle,
                      style: AppTextStyles.header2,
                    ),
                    IconButton(
                      onPressed: isSearching ? _removeFilter : _showFilterModal,
                      icon: isSearching
                          ? Icon(Icons.filter_alt_off_rounded)
                          : Icon(Icons.filter_alt_rounded),
                    ),
                  ],
                ),
              ),
            visitorList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visitorList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: AppColor.bgColor),
                          child: ExpansionTile(
                            textColor: AppColor.secondary,
                            title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${visitorList[index]['salutation']} ${visitorList[index]['name']}',
                                              style: TextStyle(fontSize: 14),
                                              textAlign: TextAlign.end),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Organization',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${visitorList[index]['organization']}',
                                              style: TextStyle(fontSize: 14),
                                              textAlign: TextAlign.end),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Designation',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${visitorList[index]['designation']}',
                                              style: TextStyle(fontSize: 14),
                                              textAlign: TextAlign.end),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                            tilePadding: EdgeInsets.only(left: 14, right: 5),
                            collapsedIconColor: AppColor.secondary,
                            childrenPadding: const EdgeInsets.only(left: 14),
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mobile No',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text('${visitorList[index]['mobile_no']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text('${visitorList[index]['email']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Known source',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text(
                                        '${visitorList[index]['known_sources']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'City, State ',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text(
                                        '${visitorList[index]['city']}, ${visitorList[index]['state']} ',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Address',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text('${visitorList[index]['address']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pincode',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text('${visitorList[index]['pincode']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nature of Business',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Text(
                                        visitorList[index]
                                                    ['nature_of_business'] !=
                                                null
                                            ? '${visitorList[index]['nature_of_business']}'
                                            : '',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reason for visit',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Expanded(
                                      child: Text(
                                          '${visitorList[index]['reason_for_visit']}',
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.end),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product looking for',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Expanded(
                                      child: Text(
                                          '${visitorList[index]['product_looking_for']}',
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.end),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'No of appointments',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColor.grey),
                                    ),
                                    Expanded(
                                      child: Text(
                                          '${visitorList[index]['no_of_appointments']}',
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.end),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            "Name: ${visitorList[index]['salutation']} ${visitorList[index]['name']}, Organization: ${visitorList[index]['organization']}, Designation: ${visitorList[index]['designation']}, Mobile No: ${visitorList[index]['mobile_no']}, Email: ${visitorList[index]['email']}, Known Source: ${visitorList[index]['known_sources']}, Address: ${visitorList[index]['address']},  Nature of Business: ${visitorList[index]['nature_of_business']}, Reason for visit: ${visitorList[index]['reason_for_visit']}, Product looking for: ${visitorList[index]['product_looking_for']}"));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text('Visitor Details Copied'),
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
                        child: Center(child: Text('No visitors found')),
                      )
                    : Container(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!hasMore && visitorList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No more visitors')),
              ),
          ],
        ),
      ),
    );
  }
}
