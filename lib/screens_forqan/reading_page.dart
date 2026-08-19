import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nour_alislam_offline/png_viewer_page.dart';
import '../BookFunctionsClass.dart';
import 'surah_forqan.dart';
import 'NewWidgetSpan.dart';
import 'WidgetSpanWrapper.dart';
import 'package:qcf_quran/qcf_quran.dart' as quran;
import 'GClassFunction.dart';


class SurahPage extends StatefulWidget {
  final Surah surah;
  final int? aya;
  const SurahPage({super.key, required this.surah, this.aya});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey<WidgetSpanWrapperState>> _ayaKeys = {};
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _scrollToAya(int aya) {
    if (_hasScrolled) return;
    
    final key = _ayaKeys[aya];
    if (key != null && key.currentContext != null) {
      final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      
      final RenderBox? scrollBox = context.findRenderObject() as RenderBox?;
      if (scrollBox == null) return;
      
      final localPosition = scrollBox.globalToLocal(position);
      
      // Calculate target offset to center the aya
      double targetOffset = _scrollController.offset + localPosition.dy - (MediaQuery.of(context).size.height / 2);
      
      if (_scrollController.hasClients) {
        targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _hasScrolled = true;
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int count = widget.surah.versesCount;
    int index = widget.surah.id;

    final alignmentKeys = <GlobalKey<WidgetSpanWrapperState>>[];

    GlobalKey<WidgetSpanWrapperState> nextKey(int ayaNum) {
      GlobalKey<WidgetSpanWrapperState> key = GlobalKey<WidgetSpanWrapperState>();
      alignmentKeys.add(key);
      _ayaKeys[ayaNum] = key;
      return key;
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (alignmentKeys.isNotEmpty) {
        List<GlobalKey<WidgetSpanWrapperState>> keysCopy = List.from(alignmentKeys);
        List<GlobalKey<WidgetSpanWrapperState>>? sameRow;
        GlobalKey<WidgetSpanWrapperState> prev = keysCopy.removeAt(0);
        for (var key in keysCopy) {
          if (getYOffsetOf(key) == getYOffsetOf(prev)) {
            sameRow ??= [prev];
            sameRow.add(key);
          } else if (sameRow != null) {
            resolveSameRow(sameRow);
            sameRow = null;
          }
          prev = key;
        }
        if (sameRow != null) {
          resolveSameRow(sameRow);
        }
      }

      if (widget.aya != null) {
        _scrollToAya(widget.aya!);
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          minimum: const EdgeInsets.all(15),
          child: ListView(
            controller: _scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: header(),
              ),
              const SizedBox(
                height: 5,
              ),
              RichText(
                textAlign: count <= 20 ? TextAlign.center : TextAlign.justify,
                text: TextSpan(
                  children: [
                    for (var i = 1; i <= count; i++)...{

                      TextSpan(
                        recognizer: TapGestureRecognizer()..onTap = () {
                          print('surah : ${widget.surah.id} $i tapped');
                          int bookNum=1;
                          int pageNum=1;
                          (bookNumber: bookNum,pageNumber: pageNum)=BookFunctionsClass.findBookPageFromSurahVerse(surah: index,verse: 1);
                          print(bookNum);
                          print(pageNum);

                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                 PngViewerPage(bookNumber: bookNum, pageNumber: pageNum),
                            ),
                          );
                        },
                        text: ' ${quran.getVerse(index, i, verseEndSymbol: false)} ',
                        style: const TextStyle(
                          fontFamily: 'Othmani',
                          fontSize: 25,
                          color: Colors.black87,
                        ),
                      ),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap: (){
                            print('surah : ${widget.surah.id} $i tapped');
                          },
                          child: WidgetSpanWrapper(
                            key: nextKey(i),
                            child: NewWidgetSpan(color: Colors.lightGreen, order: i),
                          ),
                        ),
                      ),

                      //////////////////////////////
                    }
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.surah.arabicName,
          style: const TextStyle(
            fontFamily: 'Aldhabi',
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' ${quran.getVerse(1, 1)} ',// basmalah
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'NotoNastaliqUrdu',
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}