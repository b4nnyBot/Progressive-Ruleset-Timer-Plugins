# [TF2] Improved Match Timer
 5CP round win limit gets reduced to the current highest score +1 when the match timer runs out.  For example, if the score is 1 - 2 when the map timer runs out, the win limit will be set to 3 and round continues.
 
# Why Use This Plugin?
 All current competitive rulesets for the 5CP gametype include a timer that sets a hard time limit on matches. Match timers reduce competitive integrity in the 5CP gametype. In its current form, the timer kills comebacks, causes anticlimactic endings, and encourages teams to run down the clock.

 Improved Match Timer reduces the length of matches without encouraging timer related strategies. It allows for exciting comebacks, makes every match end in a last capture, and discourages running down the clock.

# How to Install
 You'll need SourceMod installed on your server before installing Improved Match Timer.

 Place the addons folder into the tf directory.

 # How to Use
 Improved Match Timer creates a new cvar named "mp_timelimit_improved" which is by default 0. This means that the plugin by default does nothing. I recommend that you change this cvar only through ruleset related configs. I've provided a modified rgl_6s_5cp_scrim config that contains "mp_timelimit_improved 1" as an example.

 The plugin is only active on cp_ maps when mp_timelimit is above 0 and mp_timelimit_improved is set to 1. These conditions must be met before the match begins. If the plugin is active, you should see the phrase "Running Improved Match Timer..." in chat after the match starts. If you need to toggle the plugin, simply exec a config with mp_timelimit_improved changed before readying up.

# Related Plugins
 [Improved Round Timer](https://github.com/b4nnyBot/TF2-Improved-Round-Timer-Plugin)
