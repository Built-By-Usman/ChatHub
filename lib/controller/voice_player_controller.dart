import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  var currentUrl = ''.obs;
  var isPlaying = false.obs;
  var isLoading = false.obs;

  var durationMap = <String, Duration>{}.obs;
  var position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();

    _player.durationStream.listen((d) {
      if (d != null && currentUrl.value.isNotEmpty) {
        durationMap[currentUrl.value] = d;
      }
    });

    _player.positionStream.listen((p) {
      position.value = p;
    });

    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      isLoading.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      if (state.processingState == ProcessingState.completed) {
        stop();
      }
    });
  }

  // New method: Preload duration without playing

  Future<void> preloadDuration(String url) async {
    if (durationMap[url] != null && durationMap[url] != Duration.zero) {
      return;
    }

    final tempPlayer = AudioPlayer();

    try {
      await tempPlayer.setUrl(url);

      Duration? dur;
      try {
        dur = await tempPlayer.durationStream
            .firstWhere((d) => d != null && d > Duration.zero)
            .timeout(const Duration(seconds: 6));
      } catch (e) {
        // Timeout or other error → dur remains null
      }

      if (dur != null) {
        durationMap[url] = dur;
      }
    } catch (e) {
      // print('Preload failed for $url: $e');
    } finally {
      tempPlayer.dispose();
    }
  }

  Future<void> play(String url) async {
    try {
      if (currentUrl.value != url) {
        await _player.setUrl(url);
        currentUrl.value = url;
      }
      await _player.play();
    } catch (_) {
      isLoading.value = false;
    }
  }

  Future<void> pause() async => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    position.value = Duration.zero;
  }

  Future<void> seek(Duration value) async =>
      _player.seek(value);

  Duration getDuration(String url) =>
      durationMap[url] ?? Duration.zero;

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}