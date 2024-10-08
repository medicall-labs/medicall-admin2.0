import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../../Providers/local_data.dart';
import '../../Sevices/api_services.dart';
import '../../Utils/Constants/api_collection.dart';
import '../../Utils/Constants/app_color.dart';
import '../../Utils/Constants/styles.dart';
import '../../Utils/Widgets/back_button.dart';

class Delegates extends StatefulWidget {
  const Delegates({super.key});

  @override
  State<Delegates> createState() => _DelegatesState();
}

class _DelegatesState extends State<Delegates> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  List<dynamic> delegatesList = [];
  bool isLoading = false;
  bool hasMore = true;
  var baseUrl = AppUrl.baseUrl;
  late int eventId;
  bool search = false;
  String searchApi = '';

  var eventDetails = GetStorage().read("event_details") ?? '';

  String? selectedSeminarId;
  bool isSearching = false;
  List<dynamic> seminarList = [];

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
      _loadDelegates(null); // Initial API call with eventId
    });

    if (eventDetails.isNotEmpty) {
      var decodedEventDetails = eventDetails;
      if (decodedEventDetails.containsKey('seminars')) {
        seminarList = decodedEventDetails['seminars'];
      }
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMore) {
      var nextCursor = GetStorage().read("DelegatesMaster");
      if (nextCursor != null &&
          nextCursor['paginate_data']['next_cursor'] != null) {
        _loadDelegates(nextCursor['paginate_data']['next_cursor']);
      }
    }
  }

  Future<void> _loadDelegates(nextCursor) async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    String query =
        '$baseUrl/admin/delegates?event_id=$eventId&cursor=$nextCursor';

    if (searchController.text.isNotEmpty) {
      query += '&search=${searchController.text}';
    }
    if (selectedSeminarId != null) {
      query += '&seminar=$selectedSeminarId';
    }
    var result = await RemoteService().getDataFromApi(query);
    GetStorage().write("DelegatesMaster", result);

    if (result is Map<String, dynamic> && result['delegates'] != null) {
      setState(() {
        delegatesList.addAll(result['delegates']);
        hasMore = result['delegates'].length > 0;
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

      selectedSeminarId = null;

      isSearching = false;
      delegatesList = [];
      _loadDelegates(null);
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
                value: selectedSeminarId,
                decoration: InputDecoration(labelText: 'Select Seminar'),
                items: seminarList.map<DropdownMenuItem<String>>((seminar) {
                  return DropdownMenuItem<String>(
                    value: seminar['id'].toString(), // Use seminar ID as value
                    child: Text(
                        seminar['title']), // Show seminar title in dropdown
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeminarId = value;
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
      delegatesList = [];
      _loadDelegates(null);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          'Delegates',
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
                  IconButton(
                    onPressed: isSearching ? _removeFilter : _showFilterModal,
                    icon: isSearching
                        ? Icon(Icons.filter_alt_off_rounded)
                        : Icon(Icons.filter_alt_rounded),
                  ),
                ],
              ),
            ),
            delegatesList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: delegatesList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Name :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      '${delegatesList[index]['name']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Mobile number :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      '${delegatesList[index]['mobile_number']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Email :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      '${delegatesList[index]['email']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Designation :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      '${delegatesList[index]['designation']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Organization :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      '${delegatesList[index]['organization']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Seminars :',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.grey),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          NeverScrollableScrollPhysics(), // Prevent nested scrolling
                                      itemCount: delegatesList[index]
                                              ['seminars']
                                          .length,
                                      itemBuilder: (context, seminarIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 5),
                                          child: Text(
                                            '• ${delegatesList[index]['seminars'][seminarIndex]['seminar_name']}',
                                            style: AppTextStyles.label3,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : !isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No Delegates found')),
                      )
                    : Container(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!hasMore && delegatesList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No more Delegates')),
              ),
          ],
        ),
      ),
    );
  }
}
