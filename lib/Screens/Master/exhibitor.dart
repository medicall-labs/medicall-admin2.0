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

class ExhibitorMaster extends StatefulWidget {
  final bool? isMasters;
  const ExhibitorMaster({super.key, this.isMasters});

  @override
  State<ExhibitorMaster> createState() => _ExhibitorMasterState();
}

class _ExhibitorMasterState extends State<ExhibitorMaster> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> exhibitorList = [];
  bool isLoading = false;
  bool hasMore = true;
  var baseUrl = AppUrl.baseUrl;
  late int eventId;
  bool search = false;
  String searchApi = '';

  TextEditingController searchController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? sortDirection;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    // Fetch the eventId from LocalDataProvider when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localDataProvider =
          Provider.of<LocalDataProvider>(context, listen: false);
      setState(() {
        eventId = localDataProvider.eventId;
      });
      _loadExhibitors(null); // Initial API call with eventId
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      var nextCursor = GetStorage().read("ExhibitorMaster");
      if (nextCursor != null &&
          nextCursor['paginate_data']['next_cursor'] != null) {
        _loadExhibitors(nextCursor['paginate_data']['next_cursor']);
      }
    }
  }

  Future<void> _loadExhibitors(nextCursor) async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    String query = widget.isMasters == true
        ? '$baseUrl/admin/exhibitors?cursor=$nextCursor'
        : '$baseUrl/admin/exhibitors?event_id=$eventId&cursor=$nextCursor';

    if (searchController.text.isNotEmpty) {
      query += '&search=${searchController.text}';
    }
    if (startDate != null) {
      query += '&start_date=${startDate!.toLocal().toString().split(' ')[0]}';
    }
    if (endDate != null) {
      query += '&end_date=${endDate!.toLocal().toString().split(' ')[0]}';
    }
    if (sortDirection != null) {
      query += '&sort_direction=$sortDirection';
    }

    var result = await RemoteService().getDataFromApi(query);
    GetStorage().write("ExhibitorMaster", result);

    if (result is Map<String, dynamic> && result['exhibitors'] != null) {
      setState(() {
        exhibitorList.addAll(result['exhibitors']);
        hasMore = result['exhibitors'].length > 0;
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

      startDate = null;
      endDate = null;

      sortDirection = null;

      isSearching = false;
      exhibitorList = [];
      _loadExhibitors(null);
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
      exhibitorList = [];
      _loadExhibitors(null);
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
          widget.isMasters == true ? 'Exhibitor Master' : 'Exhibitors List',
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
            exhibitorList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exhibitorList.length,
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
                                        'Company',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColor.grey),
                                      ),
                                      Expanded(
                                        child: Text(
                                            '${exhibitorList[index]['company']}',
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: MediaQuery.of(context).size.width -
                                      50,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contact person',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColor.grey),
                                      ),
                                      Expanded(
                                        child: Text(
                                            '${exhibitorList[index]['contact_person']}',
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: MediaQuery.of(context).size.width -
                                      50,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Contact No',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColor.grey),
                                      ),
                                      Expanded(
                                        child: Text(
                                            '${exhibitorList[index]['contact_no']}',
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            tilePadding: EdgeInsets.only(left: 14,right: 5),
                            collapsedIconColor: AppColor.secondary,
                            childrenPadding:
                                const EdgeInsets.only(left: 14),
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width -
                                            50,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Stall No',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColor.grey),
                                            ),
                                            Text(
                                                '${exhibitorList[index]['stall_no']}',
                                                style: TextStyle(fontSize: 14),
                                                textAlign: TextAlign.end),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: MediaQuery.of(context).size.width -
                                            50,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Stall space',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColor.grey),
                                            ),
                                            Text(
                                                '${exhibitorList[index]['stall_space']}',
                                                style: TextStyle(fontSize: 14),
                                                textAlign: TextAlign.end),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: MediaQuery.of(context).size.width -
                                            50,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Square space',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColor.grey),
                                            ),
                                            Text(
                                                '${exhibitorList[index]['square_space']}',
                                                style: TextStyle(fontSize: 14),
                                                textAlign: TextAlign.end),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // IconButton(
                                  //   tooltip: "Update Stall details",
                                  //   icon: Icon(
                                  //       Icons.edit_note_rounded),
                                  //   onPressed: () {
                                  //     showDialog(
                                  //         context: context,
                                  //         builder: (BuildContext
                                  //         context) {
                                  //           String? dropdownValue;
                                  //           TextEditingController
                                  //           textController1 =
                                  //           TextEditingController();
                                  //           TextEditingController
                                  //           textController2 =
                                  //           TextEditingController();
                                  //
                                  //           return AlertDialog(
                                  //             title: Text(
                                  //                 "Update Stall details"),
                                  //             content: Column(
                                  //               mainAxisSize:
                                  //               MainAxisSize
                                  //                   .min,
                                  //               crossAxisAlignment:
                                  //               CrossAxisAlignment
                                  //                   .start,
                                  //               children: [
                                  //                 Text(
                                  //                   'Select Stall Type', // Label text
                                  //                 ),
                                  //                 SizedBox(
                                  //                     height: 8.0),
                                  //                 Container(
                                  //                   padding: EdgeInsets
                                  //                       .symmetric(
                                  //                       horizontal:
                                  //                       12.0),
                                  //                   decoration:
                                  //                   BoxDecoration(
                                  //                     border: Border.all(
                                  //                         color: AppColor
                                  //                             .secondary), // Border color
                                  //                     borderRadius:
                                  //                     BorderRadius
                                  //                         .circular(
                                  //                         5.0), // Border radius
                                  //                   ),
                                  //                   child:
                                  //                   DropdownButtonFormField<
                                  //                       String>(
                                  //                     value:
                                  //                     dropdownValue,
                                  //                     onChanged:
                                  //                         (String?
                                  //                     newValue) {
                                  //                       dropdownValue =
                                  //                           newValue;
                                  //                     },
                                  //                     items: <String>[
                                  //                       'Shell Space',
                                  //                       'Bare Space'
                                  //                     ].map<
                                  //                         DropdownMenuItem<
                                  //                             String>>((String
                                  //                     value) {
                                  //                       return DropdownMenuItem<
                                  //                           String>(
                                  //                         value:
                                  //                         value,
                                  //                         child:
                                  //                         Text(
                                  //                           value,
                                  //                           style:
                                  //                           TextStyle(
                                  //                             fontSize:
                                  //                             16.0,
                                  //                           ),
                                  //                         ),
                                  //                       );
                                  //                     }).toList(),
                                  //                   ),
                                  //                 ),
                                  //                 SizedBox(
                                  //                     height: 16.0),
                                  //                 TextField(
                                  //                   controller:
                                  //                   textController1,
                                  //                   decoration:
                                  //                   InputDecoration(
                                  //                     labelText:
                                  //                     'Stall No',
                                  //                     labelStyle:
                                  //                     TextStyle(
                                  //                       color: AppColor
                                  //                           .black,
                                  //                     ),
                                  //                     focusedBorder:
                                  //                     OutlineInputBorder(
                                  //                       borderSide:
                                  //                       BorderSide(
                                  //                           color:
                                  //                           AppColor.secondary),
                                  //                     ),
                                  //                     border:
                                  //                     OutlineInputBorder(
                                  //                       borderSide:
                                  //                       BorderSide(
                                  //                         color: AppColor
                                  //                             .black,
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 SizedBox(
                                  //                     height: 16.0),
                                  //                 TextField(
                                  //                   controller:
                                  //                   textController2,
                                  //                   decoration:
                                  //                   InputDecoration(
                                  //                     labelText:
                                  //                     'Square Space',
                                  //                     labelStyle:
                                  //                     TextStyle(
                                  //                       color: AppColor
                                  //                           .black,
                                  //                     ),
                                  //                     focusedBorder:
                                  //                     OutlineInputBorder(
                                  //                       borderSide:
                                  //                       BorderSide(
                                  //                           color:
                                  //                           AppColor.secondary),
                                  //                     ),
                                  //                     border:
                                  //                     OutlineInputBorder(
                                  //                       borderSide:
                                  //                       BorderSide(
                                  //                           color:
                                  //                           AppColor.secondary),
                                  //                     ), // Add a border around the text field
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             actions: [
                                  //               TextButton(
                                  //                 onPressed: () {
                                  //                   Navigator.of(
                                  //                       context)
                                  //                       .pop();
                                  //                 },
                                  //                 child: Text(
                                  //                     'Cancel'),
                                  //               ),
                                  //               ElevatedButton(
                                  //                 onPressed:
                                  //                     () async {},
                                  //                 //     {
                                  //                 //   String stallNo =
                                  //                 //       textController1
                                  //                 //           .text;
                                  //                 //   String sqSpace =
                                  //                 //       textController2
                                  //                 //           .text;
                                  //                 //
                                  //                 //   var updateResult =
                                  //                 //   await exhibitorCtrl.stallDetails(
                                  //                 //       details[
                                  //                 //       'exhibitor_id'],
                                  //                 //       stallNo,
                                  //                 //       dropdownValue,
                                  //                 //       sqSpace);
                                  //                 //
                                  //                 //   Navigator.of(
                                  //                 //       context)
                                  //                 //       .pop();
                                  //                 //   setState(() {});
                                  //                 // },
                                  //                 child:
                                  //                 Text('Save'),
                                  //               ),
                                  //             ],
                                  //           );
                                  //         });
                                  //   },
                                  // ),
                                ],
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
                                          fontSize: 14,
                                          color: AppColor.grey),
                                    ),
                                    Text(
                                        '${exhibitorList[index]['email']}',
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
                                      'Company Phone No',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.grey),
                                    ),
                                    Text(
                                        '${exhibitorList[index]['phone_no']}',
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
                                      'Address',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.grey),
                                    ),
                                    Text(
                                        '${exhibitorList[index]['address']}',
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
                                      'Products',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.grey),
                                    ),
                                    Expanded(
                                      child: Text(
                                          '${exhibitorList[index]['products']}',
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
                                          fontSize: 14,
                                          color: AppColor.grey),
                                    ),
                                    Text(
                                        '${exhibitorList[index]['no_of_appointments']}',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.end),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            "Company: ${exhibitorList[index]['company']}, Contact person: ${exhibitorList[index]['contact_person']}, Contact No: ${exhibitorList[index]['contact_no']},Stall No: ${exhibitorList[index]['stall_no']}, Stall space: ${exhibitorList[index]['stall_space']}, Square space: ${exhibitorList[index]['square_space']}, Email: ${exhibitorList[index]['email']}, Company Phone No: ${exhibitorList[index]['phone_no']}, Address: ${exhibitorList[index]['address']}, Products: ${exhibitorList[index]['products']}"));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                            'Exhibitor Details Copied'),
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
            if (!hasMore && exhibitorList.isNotEmpty)
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
