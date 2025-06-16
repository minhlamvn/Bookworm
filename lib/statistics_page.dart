import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'book_lists.dart';
import 'book.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    int totalBooks = context.watch<Unread>().getUnreadBooks().length +
        context.watch<InProgress>().getInProgressBooks().length +
        context.watch<Finished>().getFinishedBooks().length;
    Duration totalTime = context.watch<Unread>().getTimeUnread() +
        context.watch<InProgress>().getTimeInProgress() +
        context.watch<Finished>().getTimeFinished();
    List<Book> allBooks = context.watch<Unread>().getUnreadBooks() +
        (context.watch<InProgress>().getInProgressBooks()) +
        context.watch<Finished>().getFinishedBooks();
    allBooks.sort((book1,book2) => book2.readingTime.compareTo(book1.readingTime));
    List<Book> topBooks;
    if (allBooks.length >= 3) {topBooks = allBooks.sublist(0,3);}
    else {
      topBooks = allBooks;
      while (topBooks.length < 3) {
        topBooks.add(Book('','','',const Duration(seconds: 0)));
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height*1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8 * 0.6),
                      ),
                      child: Center(
                        child: Text(
                          '$totalBooks Book(s) in your Library!',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        TitledContainer(
                          title: 'Unread',
                          key: const Key('unread_number'),
                          child: Text(
                            context.watch<Unread>().getUnreadNumber(),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        TitledContainer(
                          title: 'In Progress',
                          key: const Key('in_progress_number'),
                          child: Text(
                            context.watch<InProgress>().getInProgressNumber(),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        TitledContainer(
                          title: 'Finished',
                          key: const Key('finished_number'),
                          child: Text(
                            context.watch<Finished>().getFinishedNumber(),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8 * 0.6),
                            ),
                            child: Center(
                              child: Text(
                                'You\'ve read a total of ${totalTime.inMinutes} Minutes!',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Longest Reads', style: TextStyle(fontSize: 22)),
                    SizedBox(
                      height: 300,
                      child: BarGraph(topBooks),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitledContainer extends StatelessWidget {
  const TitledContainer({required this.title,  Key? key, required this.child}) : super(key: key);
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 50,
          width: 110,
          margin: const EdgeInsets.only(top: 26),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(8*0.6),
          ),
          child: child,
        ),
        Positioned(
          left: 5,
          right: 10,
          top: 0,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(8*0.6)
              ),
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class BarGraph extends StatelessWidget {
  final List<Book> books;
  const BarGraph(this.books, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(
                  toY: books[2].readingTime.inSeconds*1.0,
                  color: Colors.blue
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(
                  toY: books[1].readingTime.inSeconds*1.0,
                  color: Colors.blueAccent
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(
                  toY: books[0].readingTime.inSeconds*1.0,
                  color: Colors.indigo
                )
              ]
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: bottomAxisTitles(books)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
          ),
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: false)
        )
      )
    );
  }
}

bottomAxisTitles(List<Book> books) {
  return SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      String text = '';
      switch (value.toInt()) {
        case 0:
          text = books[2].name;
          break;
        case 1:
          text = books[1].name;
          break;
        case 2:
          text = books[0].name;
          break;
      }
      return SizedBox(
          width: 80,
          child: Text(text, overflow: TextOverflow.ellipsis)
      );
    },
  );
}