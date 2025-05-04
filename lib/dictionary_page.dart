import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:free_english_dictionary/free_english_dictionary.dart';
import 'package:audioplayers/audioplayers.dart';

class DictionaryHomePage extends StatefulWidget {
  const DictionaryHomePage({super.key});

  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _word = '';
  String _definition = '';
  String _phonetics = '';
  String? _audioUrl;
  bool _isLoading = false;
  bool _isAudioLoading = false;
  bool _isPlaying = false;

  Future<void> _searchWord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var meanings = await FreeDictionary.getWordMeaning(word: _word);
      if (meanings.isNotEmpty) {
        setState(() {
          _phonetics = meanings.first.phonetics
                  ?.map((phonetic) {
                    if (phonetic.audio != null &&
                        phonetic.audio!.contains('http')) {
                      _audioUrl = phonetic.audio;
                    }
                    return phonetic.text != null ? '${phonetic.text}' : '';
                  })
                  .where((element) => element.isNotEmpty)
                  .join('\n') ??
              '';

          _definition = meanings.first.meanings!.map((meaning) {
            String partOfSpeechHeader = '${meaning.partOfSpeech}:';
            String definitions = meaning.definitions!
                .map((def) => '• ${def.definition}')
                .join('\n');
            return '$partOfSpeechHeader\n$definitions';
          }).join('\n\n');
        });
      } else {
        setState(() {
          _definition = 'No definition found.';
        });
      }
    } catch (e) {
      setState(() {
        _definition = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playAudio() async {
    if (_audioUrl != null) {
      setState(() {
        _isAudioLoading = true;
      });

      await _audioPlayer.play(UrlSource(_audioUrl!));

      setState(() {
        _isAudioLoading = false;
        _isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[400]!,
                Colors.purple[600]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[200]!,
              Colors.purple[400]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Enter a word',
                          labelStyle: TextStyle(
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.purple[400]!,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.purple[600]!,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.purple[600]),
                            onPressed: () {
                              // Clear the text field
                              _controller.clear();
                              setState(() {
                                _word =
                                    ''; // Update the state variable if needed
                                _definition = '';
                                _phonetics = '';
                                _audioUrl = '';
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _word = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _word.isNotEmpty ? _searchWord : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.purple[600]!),
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_phonetics.isNotEmpty)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _word,
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.purple[800],
                                                  ),
                                                ),
                                                Text(
                                                  _phonetics,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_audioUrl != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  boxShadow: _isPlaying
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.blue,
                                                            spreadRadius: 1,
                                                            blurRadius: 5,
                                                            offset:
                                                                Offset(0, 0),
                                                          ),
                                                        ]
                                                      : [],
                                                ),
                                                child: IconButton(
                                                  icon: _isAudioLoading
                                                      ? SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              Colors
                                                                  .purple[600]!,
                                                            ),
                                                          ),
                                                        )
                                                      : AnimatedSwitcher(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          child: Icon(
                                                            _isPlaying
                                                                ? Icons
                                                                    .volume_up
                                                                : Icons
                                                                    .volume_down,
                                                            color: _isPlaying
                                                                ? Colors.blue
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                  onPressed: _isAudioLoading
                                                      ? null
                                                      : _playAudio,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    SizedBox(height: 15),
                                    BoldColonText(
                                      _definition,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoldColonText extends StatelessWidget {
  final String text;

  BoldColonText(this.text);

  @override
  Widget build(BuildContext context) {
    List<String> parts = text.split(':');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();

      if (i < parts.length - 1) {
        List<String> words = part.split(' ');

        if (words.isNotEmpty) {
          String lastWord = words.last;
          String remainingText = words.sublist(0, words.length - 1).join(' ');

          textSpans.add(TextSpan(
              text: remainingText.isNotEmpty ? '$remainingText ' : '',
              style: TextStyle(fontWeight: FontWeight.normal)));
          textSpans.add(TextSpan(
              text: '$lastWord: ',
              style: TextStyle(fontWeight: FontWeight.bold)));
        }
      } else {
        textSpans.add(TextSpan(
            text: part, style: TextStyle(fontWeight: FontWeight.normal)));
      }
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          height: 1.5,
        ),
      ),
    );
  }
}
