# NTSS
# Nontrivial Sound System at 111 / UdK Berlin
Bruno Gola, Alberto de Campo, 2025/6

NTSS is a NonTrivial Sound System, developed by link::https://s4ntp.org::.

It is a sound system built for diversity of loudspeaker sound colors,
and currently consists of 26 loudspeakers set up at UdK Berlin Medienhaus room 111.

## Install Software:
// Install the NTSS quark
Quarks.install("https://github.com/aiberlin/NTSS");
// update your installed quarks
Quarks.installed.do(_.update);

// recompile -> ready!


##Turn the NTSS Hardware ON:

1. Check that Black Distributor 2 AMPS right side is OFF,
and if not, TURN IT OFF!
-> AMPS On the table ARE OFF NOW.

2. Turn on White Power distributor 1 COMP:
-> Audio interfaces are ON now:
  Behringer X-32 Mixer
  Behringer S16 Expander
  RME ADI 8 Pro

3. Connect Laptop to USB plug w extender,
choose a good location to sit...
Open SuperCollider ...

If you use StartupFile:
** switch to NTSS_dev
** recompile
-> N_T_S_S comes up
If not:
** run xstartup_example_NTSS

4. Turn ON Black Distributor 2 AMPS,
little amps next to Yamaha, and
-> YAMAHA, Denon, and the little amps are on.
Genelec on Stand, power dist in the cupboard
-> Genelec, Behringer guitar amp and BlueCab bass amp are on


5. In SuperCollider, the screen looks like this:

On the N_T_S_S window, turn up mainvol to maybe 0.25
in MainFX, you can see the parameter mainvol move.

Open one channel GUI, e.g. ch1ada
Turn up noiseAmp
-> you should see levels move in the top NdefGui

Depending on panfunc, also already on SpatioScope?
To test, go to GUI ch1ada lower half,
switch panfunc to dbap,
and move the controls:
dbap_x - sound moves left/right
dbap_y - sound moves front / back (up down on Spatio)
dbap_k - sound spreads to more or fewer speakers.

6. Test that all channels work:
switch panFunc to direct,
and step direct_out slider from 0, 1, 2, 3, .. 25:
-> every speaker should sound!

