import 'package:flutter/material.dart';

import 'data_Files/Book_final.dart';

class PngViewerPage extends StatefulWidget {
  const PngViewerPage({
    super.key,
    required this.bookNumber,
    required this.pageNumber,
  });

  final int bookNumber;
  final int pageNumber;

  @override
  State<PngViewerPage> createState() => _PngViewerPageState();
}

class _PngViewerPageState extends State<PngViewerPage> {
  late int _pageNumber;

  int get _maxPageNumber => booksLimit[widget.bookNumber - 1] + 5;

  bool get _canGoPrevious => _pageNumber > 1;

  bool get _canGoNext => _pageNumber < _maxPageNumber;

  String get _imagePath {
    final paddedPage = _pageNumber.toString().padLeft(3, '0');
    return 'assets/book/part${widget.bookNumber}/K${widget.bookNumber}-$paddedPage.jpg';
  }

  @override
  void initState() {
    super.initState();
    _pageNumber = widget.pageNumber.clamp(1, _maxPageNumber).toInt();
  }

  void _goPrevious() {
    if (!_canGoPrevious) return;
    setState(() => _pageNumber--);
  }

  void _goNext() {
    if (!_canGoNext) return;
    setState(() => _pageNumber++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الجزء ${widget.bookNumber} - الصفحة $_pageNumber'),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/icons/exit.png', width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.asset(
                    _imagePath,
                    key: ValueKey(_imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'تعذر تحميل صورة الصفحة',
                        style: TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArrowButton(
                    assetPath: 'assets/icons/left_arrow.png',
                    enabled: _canGoPrevious,
                    onPressed: _goPrevious,
                  ),
                  Text(
                    '$_pageNumber / $_maxPageNumber',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _ArrowButton(
                    assetPath: 'assets/icons/right_arrow.png',
                    enabled: _canGoNext,
                    onPressed: _goNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.assetPath,
    required this.enabled,
    required this.onPressed,
  });

  final String assetPath;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      iconSize: 40,
      onPressed: enabled ? onPressed : null,
      icon: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Image.asset(assetPath, width: 36, height: 36),
      ),
    );
  }
}
