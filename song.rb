# Set the tempo and chords to be used
use_bpm 60
chord_d = chord(:d3, :major)
chord_fsharpm = chord(:fs3, :minor)
chord_e = chord(:e3, :minor)
chord_bm = chord(:b2, :minor)


# Airport announcement chime with reverb
define :announcement do
  with_fx :reverb, room: 0.8 do
    use_synth :sine
    play :f4, amp: 2, release: 0.75
    sleep 1.0
    play :d4, amp: 2, attack: 0.1, release: 2.0
    sleep 3.0
  end
end


# Taking off and Landing sounds
define :takeoff_landing do |start_pitch, end_pitch|
  # Increasing Whirring of Engine
  use_synth :noise
  p1 = play 10, sustain: 12, cutoff: 30, cutoff_slide: 4, amp: 0.6
  control p1, cutoff: 80
  
  sleep 4
  # High-pitched mechanism emulation
  use_synth :sine
  p = play start_pitch, sustain: 8, amp: 0.01
  sleep 2
  control p, note: end_pitch, slide: 6
  sleep 6
end


# Background ambient sounds with reverb and turbulence
in_thread do
  sync :ambience
  300.times do
    with_fx :reverb, room: 0.8 do
      # Ambient sounds
      sample :ambi_lunar_land, rate: 0.3, amp: 0.02
      
      # Turbulence rumbling with shaky and random bass drum
      with_fx :lpf, cutoff: 80, cutoff_slide: 4 do
        sample :bd_808, rate: rrand(0.1, 0.16), amp: rrand(0.02, 0.05)
        sleep 1
      end
    end
  end
end


# Drum Beat
in_thread do
  sync :ambience
  150.times do
    with_fx :reverb, room: 0.5 do
      sample :perc_bell, rate: 0.8, amp: 0.01
    end
    sample :drum_bass_hard, amp: 0.05
    sleep 0.75
    sample :drum_bass_hard, amp: 0.05
    sleep 0.25
    sample :drum_snare_hard, amp: 0.05
    sleep 1
  end
end


#Bass Melody
in_thread do
  loop do
    sync :melody
    use_synth :fm
    options = { #bass settings
                release: 0.5, amp: 0.6, pluck: 0.8, pluck_release: 0.1, pluck_resonance: 0.3,
                pluck_damping: 0.2, pluck_attack: 0.5
                }
    play :e3, options
    sleep 0.25
    play :fs3, options
    sleep 0.25
    play :g3, options
    sleep 0.25
    play :a3, options.merge(release: 2)
    sleep 2
    play :a3, options
    sleep 0.25
    play :g3, options
    sleep 0.25
    play :fs3, options
    sleep 0.25
    play :fs3, options.merge(release: 1.0)
  end
end


#Simplified Base Melody with less complex pattern
in_thread do
  loop do
    sync :simpler_melody
    use_synth :fm
    options = {
      release: 1.5, amp: 0.6, pluck: 0.1, pluck_release: 0.1, pluck_resonance: 0.8,
      pluck_damping: 0.8, pluck_attack: 0.8
    }
    play :e3, options
    sleep 1.0
    play :g3, options
    sleep 1.0
    play :a3, options
    sleep 2.0
    play :fs3, options
  end
end


#Helper Function to Call the Melody Overlays
define :play_overlay do |overlay_type|
  if overlay_type == 'melody'
    cue :melody
  end
  if overlay_type == 'simpler_melody'
    cue :simpler_melody
  end
end


#Play Consistent Underlying Chord Progression
define :play_plain_chords do |play_melody|
  play_overlay play_melody #cue potential melody overlay
  
  use_synth :hollow
  opts = {amp: 2, release: 16, attack: 0.1}
  play chord_d, opts
  sleep 8
  play chord_fsharpm, opts
  sleep 8
  
  play_overlay play_melody #cue potential melody overlay
  
  use_synth :hollow
  play chord_e, opts
  sleep 8
  play chord_bm, opts
  sleep 8
end


#Plays Up and Down Inversion Chords
define :smooth_inversions do |chord_name|
  duration = 1.0
  opts = {amp: 2, release: duration, attack: 0.9}
  
  # Play the inversions smoothly with pitch bending
  play chord_name, opts
  sleep duration
  play invert_chord(chord_name, 1), opts
  sleep duration
  play invert_chord(chord_name, 2), opts
  sleep duration
  play invert_chord(chord_name, 3), opts
  sleep duration
  play invert_chord(chord_name, 3), opts
  sleep duration
  play invert_chord(chord_name, 2), opts
  sleep duration
  play invert_chord(chord_name, 1), opts
  sleep duration
  play chord_name,  opts
  sleep duration
end


# Calls for inversion pattern of each chord to be played
define :play_inversions do |play_melody|
  play_overlay play_melody #cue potential melody overlay
  use_synth :hollow
  smooth_inversions(chord_d)
  smooth_inversions(chord_fsharpm)
  play_overlay play_melody #cue potential melody overlay
  smooth_inversions(chord_e)
  smooth_inversions(chord_bm)
end


# Another chord progression pattern that involves inversions
define :double_inversions do |chord_name|
  use_synth :hollow
  amp = 2
  2.times do
    play chord_name, release: 1.25, attack: 0.15, amp: amp
    sleep 0.75
    play chord_name, release: 0.75, attack: 0.1, amp: amp
    sleep 0.25
    play invert_chord(chord_name, 3), release: 1.5, attack: 0.17, amp: amp
    sleep 0.5
    play invert_chord(chord_name, 3), release: 1.5, attack: 0.17, amp: amp
    sleep 0.5
  end
end


# Calls for the second chord inversion pattern to be played
define :play_double_inversions do |play_melody|
  play_overlay play_melody #cue potential melody overlay
  
  use_synth :hollow
  double_inversions(chord_d)
  double_inversions(chord_fsharpm)
  
  play_overlay play_melody #cue potential melody overlay
  
  double_inversions(chord_e)
  double_inversions(chord_bm)
end


#High Level Control of the Thread
in_thread do
  #Taking Off
  announcement
  takeoff_landing 90, 105
  
  #Ongoing Ambience
  cue :ambience
  
  #Chord Progressions and Melodies
  play_plain_chords 'none'
  play_plain_chords 'melody'
  play_plain_chords 'simpler_melody'
  play_inversions 'none'
  play_inversions 'simpler_melody'
  play_double_inversions 'none'
  play_plain_chords 'melody'
  play_inversions 'melody'
  play_double_inversions 'simpler_melody'
  play_plain_chords 'none'
  
  #Landing
  announcement
  takeoff_landing 105, 90
end
