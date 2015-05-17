(function ($) {
  flowplayer.engine.dash = function(player, root) {
    var mediaPlayer,
    videoTag,
    context = new Dash.di.DashContext();

    player.bind("pause", function (e, api) {
      // work around dash.js reseting playbackRate to 1 after pause
      var speed = api.currentSpeed;

      if (speed != 1) {
        api.one("progress.dashresume", function () {
          videoTag.playbackRate = speed;
        });
      }
    });

    return {
      pick: function(sources) {
        if (!window.MediaSource) return;
        var sources = $.grep(sources, function(src) {
          return src.type === 'application/dash+xml';
        });
        if (!sources.length) return;
        return sources[0];
      },
      load: function(video) {
        root.find('video').remove();
        videoTag = document.createElement('video');
        videoTag.addEventListener('play', function() {
          root.trigger('resume', [player]);
        });
        videoTag.addEventListener('pause', function() {
          root.trigger('pause', [player]);
        });
        videoTag.addEventListener('timeupdate', function() {
          root.trigger('progress', [player, videoTag.currentTime]);
        });
        videoTag.addEventListener('loadedmetadata', function() {
          video.duration = video.seekable = videoTag.duration;
          root.trigger('ready', [player, video]);
        });
        videoTag.addEventListener('seeked', function() {
          root.trigger('seek', [player, videoTag.currentTime]);
        });
        videoTag.addEventListener('progress', function() {
          try {
            var buffered = videoTag.buffered,
                buffer = buffered.end(0), // first loaded buffer
                ct = videoTag.currentTime,
                buffend = 0;

            // buffered.end(null) will not always return the current buffer
            // so we cycle through the time ranges to obtain it
            if (ct) {
              for (i = 1; i < buffered.length; i++) {
                buffend = buffered.end(i);

                if (buffend >= ct && buffered.start(i) <= ct) {
                  buffer = buffend;
                }
              }
            }
            video.buffer = buffer;
          } catch (ignored) {}
          root.trigger('buffer', [player]);
        });
        videoTag.addEventListener('ended', function() {
          root.trigger('finish', [player]);
        });
        videoTag.addEventListener('volumechange', function() {
          root.trigger('volume', [player, videoTag.volume]);
        });


        videoTag.className = 'fp-engine dash-engine';
        root.prepend(videoTag);

        mediaPlayer = new MediaPlayer(context);
        mediaPlayer.setAutoPlay(player.conf.autoplay || player.conf.splash);
        mediaPlayer.startup();
        mediaPlayer.attachView(videoTag);
        mediaPlayer.attachSource(video.src);
      },
      resume: function() {
        if (player.finished) {
          videoTag.currentTime = 0;
        }
        videoTag.play();
      },
      pause: function() {
        videoTag.pause();
      },
      seek: function(time) {
        if (player.paused) {
          var muted = !!player.muted;

          $(videoTag).one("seeked.dashpaused", function () {
            player.pause()
            player.mute(muted);
          });

          player.mute(true);
          videoTag.play();
        }
        if (mediaPlayer !== undefined) {
          mediaPlayer.seek(time);
        } else {
          videoTag.currentTime = time;
        }
      },
      volume: function(level) {
        if (videoTag !== undefined) {
          videoTag.volume = level;
        }
      },
      speed: function(val) {
        videoTag.playbackRate = val;
        root.trigger('speed', [player, val]);
      },
      unload: function() {
        if (mediaPlayer !== undefined) {
          mediaPlayer.reset();
        }
        $(videoTag).remove();
        root.trigger("unload", [player]);
      }

    };
  };
}(jQuery));