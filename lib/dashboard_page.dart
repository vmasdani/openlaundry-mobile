import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:openlaundry/app_state.dart';
import 'package:openlaundry/document_editor.dart';
import 'package:openlaundry/helpers.dart';
import 'package:openlaundry/model.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _laundryDocumentSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DocumentEditor(
                        laundryDocument: LaundryDocument(),
                      )));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Consumer<AppState>(builder: (ctx, state, child) {
                    return Text(
                      'Documents (${state.laundryDocuments?.length ?? 0} records)',
                      style: TextStyle(fontSize: 18),
                    );
                  }),
                ),
                // Consumer<AppState>(builder: (ctx, state, child) {
                //   return Container(
                //     child: Text('${state.lastId}'),
                //   );
                // }),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Text(
                        'Search: ',
                        style: TextStyle(),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search Document',
                            isDense: true,
                          ),
                          controller: _laundryDocumentSearchController,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {});
                          })
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  child: Divider(),
                ),
                // Consumer<AppState>(
                //   builder: (ctx, state, child) {
                //     return Container(
                //       margin: EdgeInsets.all(10),
                //       child: Text(jsonEncode(state.customers)),
                //     );
                //   },
                // ),
                // Divider(),
                // Consumer<AppState>(
                //   builder: (ctx, state, child) {
                //     return Container(
                //       margin: EdgeInsets.all(10),
                //       child: Text(jsonEncode(state.laundryDocuments)),
                //     );
                //   },
                // ),
                // Divider(),
                // Consumer<AppState>(
                //   builder: (ctx, state, child) {
                //     return Container(
                //       margin: EdgeInsets.all(10),
                //       child: Text(jsonEncode(state.laundryRecords)),
                //     );
                //   },
                // ),
                // Divider(),
                Consumer<AppState>(
                  builder: (ctx, state, child) {
                    return Column(
                      children: List<LaundryDocument>.from(
                              state.laundryDocuments?.reversed ??
                                  Iterable.empty())
                          .where((laundryDocument) =>
                              laundryDocument.name?.toLowerCase().contains(
                                  _laundryDocumentSearchController.text
                                      .toLowerCase()) ??
                              false)
                          .toList()
                          .asMap()
                          .map((i, laundryDocument) => MapEntry(
                              i,
                              GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text(
                                                'Delete ${laundryDocument.name}?'),
                                            actions: [
                                              Consumer<AppState>(
                                                  builder: (ctx, state, child) {
                                                return TextButton(
                                                  child: Text('Yes'),
                                                  onPressed: () async {
                                                    if (laundryDocument.uuid !=
                                                        null) {
                                                      await state.delete<
                                                              LaundryDocument>(
                                                          laundryDocument.uuid);
                                                    }

                                                    Navigator.pop(context);
                                                  },
                                                );
                                              })
                                            ],
                                          ));
                                },
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => DocumentEditor(
                                                laundryDocument:
                                                    laundryDocument,
                                              )));
                                },
                                child: Column(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              offset: Offset(3, 3),
                                              blurRadius: 5,
                                              spreadRadius: 5)
                                        ]),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${i + 1}. ${laundryDocument.name ?? 'No name'}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Consumer<AppState>(
                                          builder: (ctx, state, child) {
                                            final income = state.laundryRecords
                                                ?.where((laundryRecord) =>
                                                    laundryRecord
                                                        .laundryDocumentUuid ==
                                                    laundryDocument.uuid)
                                                .map((laundryRecord) =>
                                                    laundryRecord.price ?? 0)
                                                .fold(
                                                    0,
                                                    (acc, laundryRecordPrice) =>
                                                        (acc as int) +
                                                        laundryRecordPrice);

                                            return Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Total income: ${NumberFormat.currency(locale: 'id-ID').format(income ?? 0)}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                              ),
                                            );
                                          },
                                        ),
                                        Divider(),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              'Date: ${makeReadableDateString(DateTime.fromMillisecondsSinceEpoch(laundryDocument.date ?? 0))}'),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${state.laundryRecords?.where((laundryRecord) => laundryRecord.laundryDocumentUuid == laundryDocument.uuid).length ?? 0} laundries'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Divider(),
                                  )
                                ]),
                              )))
                          .values
                          .toList(),
                    );
                  },
                )
              ],
            )),
      ),
    );
  }
}
