##
# Auto Voice on MP3 sharing v1.9
#  by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#
# If you have any questions/comments/suggestions/bug reports, please e`mail me.
#
# My SVS website - http://mc.purehype.net/
##

##
# This script will auto voice a user for sharing an mp3.  The script detects mp3 sharing
# via ctcp mp3 and ctcp slots (spr type serving).  Also has topic and channel posting
# features.
##

##
# History
##
#  v1.9 (03.11.01)
#   MC_8 - Added SVS v1.2
#   MC_8 - unk^ - Fixed:  The %servers replacment wasn't building a list of mp3 servers
#                 if the topic feature wasn't on, but yet the post feature was.
#
#  v1.8 (09.19.00)
#  -Added %estfilesize (estimated size of combined files).
#
#  v1.7.1 (08.22.00)
#  -Fixed, "msg already queued. skipping: PRIVMSG #channel :" anoyance.
#  -Borg script just has to be different, *sigh*.  Made this script adapt (funny hu)
#   to the borg script.
#   This fixes: Tcl error [mc:mp3voice:pre]: syntax error in expression "0+408 (1,652.20 mb)"
#   The borg script has this " " in the SLOTS files, no... it's not a chr 32 (space),
#   it's a chr 160... damn it, I almost pulled my hair out figuring that one out.
#
#  v1.7 (08.14.00)
#  -works with the new part bind format (eggdrop1.5.3 and up will need this)
#  -"(Timer) Error for 'mc:mp3:inter:-server user #channel': wrong # args:
#    should be "getchanhost nickname channel"" found by riddler.  Fixed this,
#    for the older bots.
#  -"(Timer) Error for 'mp3autov:chk_topic': bad switch "-dic": must be -ascii, -integer,
#    -real, -increasing -decreasing, or -command" found by riddler.  Changed -dic to
#    -ascii to support the older bots.
#  -"Tcl error [mc:mp3voice:pre]: wrong # args: should be "nick2hand nick channel"" found
#    by riddler.  Fixed this, for the older bots.
#  -Added %slots (Combined, avilable slots), %takenslots (Combined, free slots),
#    %que (Combined, que taken), %takenque (Combined, avilable que slots),
#    %cps (Combined, cps), %files (Combined, files avilable), %kps (Combined, k/s),
#    %freeslots (Combined, send slots free), %freeque (Combined, que slots free)
#  -Added server idle time-out feature.
#
#  v1.6 (04.08.00)
#  -Added timed channel posting option.
#  -Fixed `Tcl error [mc:mp3voice]: invalid command name "notice"', found by gigman.
#
#  v1.5.1 (03.28.00)
#  -Minor problem, faulty readout on %num for the topic.  If no servers it said there were
#    one, thinking =none= was a server.
#  -Added 0x005 and 0x006 to the language section.
#
#  v1.5  (03.18.00)
#  -Removed the commands (useless, I don't see why anyone would use them... more trouble
#    to code than it's worth)
#  -Made an easy to change language system (just for customizable reasons).
#  -Removed the /invite crap associated with mainchan (That's to close to spam).
#  -Added ability to have different topics for different rooms (more customizable).
#  -Added topic check frequency veriable (it was set at 5 min's core coded in prev versions).
#  -Servers such as SPR doesn't send RFC complent CTCP SLOT's, made a work around to compensate.
#  -Was fuxen up on special charatered nicks AGAIN... Fixed AGAIN (hopefully the last time).
#  -Removed its dependency on moretools.
#
#  v1.4  (11-22-99)
#  -Wasn't doing topic over run correctly (mp3autov(chr_topic)), fixed.
#  -Shawn found, even if mp3autov(topic) was 0, would do topic anyway, fixed that!
#
#  v1.3b (10-11-99)
#  -Fixed bug, error'd out on []{} nicks => topic checking.
#    `- fixed topic garble, on part/quit/kick was removing nick and seperating spaces for servers
#  -Now resets user database upon self join
#  -Fixed, Was eating up the CPU usage (ping timeout, shell lock up, 50-80% CPU usage)
#    ^^ was a bug in moretools 1.1.4 ^^
#  -Added mp3autov(mainchan) feature.
#
#  v1.3a (10-09-99)
#  -Added a kick bind... wasn't clearing mp3server out of topic when he was kicked.
#
#  v1.3 (??.??.99)
#  -Fixed minor bug, when no servers, it started giving out errors and not working anymore.
#
#  v1.0 - 1.2 (??.??.99)
#  -Inital Release.
#####

# What channels do you want this script to be active on?  Seperate each channel
# with a space.  Setting this to "" will make all channels active.
set mp3autov(chans) ""

# [0=no/1=yes] Do you want to autoset the topic to corilate with servers online?
# topic example:  Welcome to #mp34free, servers detected online: nick1 nick2 nick3 nick4 nick5 ...!
set mp3autov(topic) 1

# In min.s.  How often do you want to preform an update on the topic (if different)?
# This only valid if mp3autov(topic) is 1.
set mp3autov(freq) 5

# Set this for how long (in min's) before showing no sign of serving
# (CTCP SLOTS or CTCP MP3) to remove the server off the active servers list?
set mp3autov(servexr) 30

# [0=no/1=yes] In reference to servexr (the setting above), do you want to remove
# there +v status (if they have +v)?  If the usier is +v|v in the userfile, it will
# not remove there +v regardless. 
set mp3autov(servexp-v) 1

# Witch of the channels above do you wish to use the topic feature on?
# (I oper many mp3 channels, and on some... the topic is not to be changed.)
# If this is set to "" and mp3autov(topic) is set to 1, it will default to
# every channel set in the mp3autov(chans).
set mp3autov(topic_chans) "#mp34free"

# If you have the topic autoset feature turned on, you can "personalize" your topic
# message.  `set mp3topic(#THE_CHANNEL_HERE) "THE TOPIC HERE"'  So as you can see,
# you can specify different topics for different channels.  If you have many mp3 channels,
# and you want to have this topic feature on several or all of them but don't want to
# customize each one... `set mp3topic(default) "This is a default topic cuz I'm to lazy to make one up."'
# (Have I confused you?  I hope not.)
# Valid replacment veriables are:
#  %num (number of servers)
#  %chan (the channel)
#  %servers (a, list, of, servers)
#  %slots (Combined, avilable slots) 
#  %takenslots (Combined, send slots taken)
#  %que (Combined, que taken) 
#  %takenque (Combined, que slots taken)
#  %cps (Combined, cps)
#  %files (Combined, files avilable)
#  %kps (Combined, k/s)
#  %freeslots (Combined, send slots free)
#  %freeque (Combined, que slots free)
#  %estfilesize (Estimated size of all files avilable)
set mp3topic(#mp34free) "8,2%chan4(8%num 11servers4/8%files 11files4~8%estfilesize4)11 Current Servers: 8%servers11."
set mp3topic(default) "%chan is kick'n it with %num server(s): %servers"

# How many caracters will the server allow in the topic? 
# Undernet == 160
set mp3autov(chr_topic) 160

# what is your main mp3 channel (the channel you would like to promote)
# promote - if mainchan = #abc   /  someone serves in #xyz and your bot is operator
# of the channel, it will voice the user for serving, and tell that user 1 of 3 things
#  if that user is in #abc but not voiced (not serving) : says: than you for serving, please serve #abc also
#  if that user is not in #abc : says: thank you for serving, please serve #abc also
#  if that user is in #abc and voiced, says: thank you for serving.
# This may be confusing, if it is just disable it.   To disable this, set it to ""
set mp3autov(mainchan) "#mp34free"

# Do you want the bot to display a post to the channel every X amount of min's?  If so
# set this to how many min's, set to 0 to turn it off.
set mp3autov(postchan) 5

# If you have the post feature turned on, what channel(s) do you want to use this feature
# on?  Seperate each channel with a space.  Set to "" for all channels.
set mp3autov(postchans) "#mp34free"

# If you have the post feature turned on, you can "personalize" your post
# message here.  `set mp3postchan(#THE_CHANNEL_HERE) "THE POST HERE"'  So as you can see,
# you can specify different topics for different channels.  If you have many mp3 channels,
# and you want to have this topic feature on several or all of them but don't want to
# customize each one... `set mp3postchan(default) "This is a default topic cuz I'm to lazy to make one up."'
# (Have I confused you?  I hope not.)
# Valid replacment veriables are:
#  %num (number of servers)
#  %chan (the channel)
#  %servers (a, list, of, servers) 
#  %slots (Combined, avilable slots)
#  %takenslots (Combined, send slots taken)
#  %que (Combined, que taken)
#  %takenque (Combined, que slots taken)
#  %cps (Combined, cps)
#  %files (Combined, files avilable)
#  %kps (Combined, k/s)
#  %freeslots (Combined, send slots free)
#  %freeque (Combined, que slots free)
#  %estfilesize (Estimated size of all files avilable)
set mp3postchan(#mp34free) {
 12,2 1011 Welcome to 8%chan11, we have8 %num 11detected servers online to serve you:8 %servers11. 1012 
 12,2 1011 Combined channel status: 4(8%files11files4~8%estfilesize4) (8%freeslots11 Free Send Slots4)11-4(8%freeque11 Free Que Slots4)11->4\[(8%takenslots4/8%slots4)11 Slots Taken 4(8%takenque4/8%que4)11 Ques Taken4\] \[11Highest Cps Record: 8%kpsk/s4\] 111012 
}
set mp3postchan(default) "12,2 1011 Welcome to 8%chan11, we have8 %num 11detected servers online to serve you:8 %servers11. 1012 "

# For the %estfilesize, what do you want to say the average size of an mp3 is?
# In meg's.
set mp3autov(estfilesize) 5

## MC SVS (Script Version Service) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mp3autov(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mp3autov(svs:check) 0  ;#This is at Midnight
#  set mp3autov(svs:check) 5  ;#This is at 5am
#  set mp3autov(svs:check) 13  ;#This is at 1pm
#  set mp3autov(svs:check) 23  ;#This is at 11pm
set mp3autov(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mp3autov(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mp3autov(svs:stableonly) 0

##
# Language Section (If you read this and say "WTF is this?", then just leave it alone.)
##
#mp3autov(mainchan) == %chan
set mp3autov(0x001) "12 You have been voiced in %chan for sharing your mp3's, thank you."
#%nick == +v || +o of mp3autov(mainchan)
set mp3autov(0x002) "12 You have been voiced in %chan for sharing your mp3's, thank you."
#mp3autov(mainchan) == ""
set mp3autov(0x003) "12 You have been voiced in %chan for sharing your mp3's, thank you."
#%nick != +v || +o of mp3autov(mainchan) || not-on mp3autov(mainchan)
set mp3autov(0x004) "12 You have been voiced in %chan for sharing your mp3's, thank you. You are invited to serve my main channel also, %mainchan." 
# If there are not servers, %servers return this.
set mp3autov(0x005) "=none="
# This is what splits the servers.  Server1, Server2, Server3.  See the ", ", that's what this is for.
set mp3autov(0x006) "11, 8"

### Do not edit below ###
set mp3autov(version) v1.9
set mp3autov(svs:script) "mp3voice 001009000000"
set mp3autov(svs:server) "mc.purehype.net 8085"


if {$mp3autov(chans) != ""} {
 set mp3autov(chans) " [string tolower [join $mp3autov(chans) " "]] "
}
if {$mp3autov(topic_chans) != ""} {
 set mp3autov(topic_chans) " [string tolower [join $mp3autov(topic_chans) " "]] "
}
set mp3autov(mainchan) [string tolower $mp3autov(mainchan)]
if {$mp3topic(default) == ""} {set mp3topic(default) "Welcome to %chan, detected servers online: %servers!"}
if {$mp3postchan(default) == ""} {set mp3postchan(default) "12,2 1011 Welcome to 8%chan11, we have8 %num 11detected servers online to serve you:8 %servers11. 1012 "}
foreach array [array names mp3topic] {
 if {[string tolower $array] != $array} {
  set mp3topic([string tolower $array]) $mp3topic($array)
  unset mp3topic($array)
 }
}
foreach array [array names mp3postchan] {
 if {[string tolower $array] != $array} {
  set mp3postchan([string tolower $array]) $mp3postchan($array)
  unset mp3postchan($array)
 }
}
if {![string match "* mp3autov:chk_topic *" [timers]]} {timer $mp3autov(freq) "mp3autov:chk_topic"}

#logfile 2 * "debug.log"

proc mc:mp3voice {nick uhost hand chan key args} {
 global botnick mp3autov mc_mp3voice
 set chan [string tolower $chan]
 if {(![string match "* $chan *" $mp3autov(chans)]) && ($mp3autov(chans) != "")} {return 0}
 if {([string tolower $chan] == [string tolower $botnick]) || ($args == "")} {return 0}
;# Slots information ; start
 set args [join $args]
 if {($key == "SLOTS") && ([llength $args] >= "7")} {
putloglev 2 * "......"
putloglev 2 * "$nick@$chan SLOTS: $args"
if {([lindex $args 0] < [lindex $args 1]) || ([lindex $args 3] > [lindex $args 4])} {
 putloglev 2 * "WARNING: non RFC Slots ctcp"
 return
}
catch {putloglev 2 * "$nick's slots (before): $mc_mp3voice(stat:$nick:$chan)"}
catch {putloglev 2 * "$chan's slots (before): $mc_mp3voice(stat:$chan)"}
  set temp_slots [lindex $args 0]
  set temp_takenslots [expr [lindex $args 0]-[lindex $args 1]]
  set temp_takenque [lindex $args 3]
  set temp_que [lindex $args 4]
  set temp_cps [lindex $args 5]
  set temp_files [lindex $args 6]
  if {![info exists mc_mp3voice(stat:$chan)]} {
   set mc_mp3voice(stat:$chan) "0 0 0 0 0 0" ; set ver 1
  } {set ver 0}
  if {![info exists mc_mp3voice(stat:$nick:$chan)] || $ver} {
   set temp_cslots [expr [lindex $mc_mp3voice(stat:$chan) 1]+$temp_slots]
   set temp_ctakenslots [expr [lindex $mc_mp3voice(stat:$chan) 0]+$temp_takenslots]
   set temp_cque [expr [lindex $mc_mp3voice(stat:$chan) 3]+$temp_que]
   set temp_ctakenque [expr [lindex $mc_mp3voice(stat:$chan) 2]+$temp_takenque]
   set temp_ccps [expr [lindex $mc_mp3voice(stat:$chan) 4]+$temp_cps]
   set temp_cfiles [expr [lindex $mc_mp3voice(stat:$chan) 5]+$temp_files]
   set mc_mp3voice(stat:$chan) "$temp_ctakenslots $temp_cslots $temp_ctakenque $temp_cque $temp_ccps $temp_cfiles"
   set mc_mp3voice(stat:$nick:$chan) "$temp_takenslots $temp_slots $temp_takenque $temp_que $temp_cps $temp_files"
  } {
   set temp_slots2 [expr $temp_slots-[lindex $mc_mp3voice(stat:$nick:$chan) 1]]
   set temp_takenslots2 [expr $temp_takenslots-[lindex $mc_mp3voice(stat:$nick:$chan) 0]]
   set temp_que2 [expr $temp_que-[lindex $mc_mp3voice(stat:$nick:$chan) 3]]
   set temp_takenque2 [expr $temp_takenque-[lindex $mc_mp3voice(stat:$nick:$chan) 2]]
   set temp_cps2 [expr $temp_cps-[lindex $mc_mp3voice(stat:$nick:$chan) 4]]
   set temp_files2 [expr $temp_files-[lindex $mc_mp3voice(stat:$nick:$chan) 5]]
   set temp_cslots [expr [lindex $mc_mp3voice(stat:$chan) 1]+$temp_slots2]
   set temp_ctakenslots [expr [lindex $mc_mp3voice(stat:$chan) 0]+$temp_takenslots2]
   set temp_cque [expr [lindex $mc_mp3voice(stat:$chan) 3]+$temp_que2]
   set temp_ctakenque [expr [lindex $mc_mp3voice(stat:$chan) 2]+$temp_takenque2]
   set temp_ccps [expr [lindex $mc_mp3voice(stat:$chan) 4]+$temp_cps2]
   set temp_cfiles [expr [lindex $mc_mp3voice(stat:$chan) 5]+$temp_files2]
   set mc_mp3voice(stat:$chan) "$temp_ctakenslots $temp_cslots $temp_ctakenque $temp_cque $temp_ccps $temp_cfiles"
   set mc_mp3voice(stat:$nick:$chan) "$temp_takenslots $temp_slots $temp_takenque $temp_que $temp_cps $temp_files"
  }
putloglev 2 * "$nick's slots: $mc_mp3voice(stat:$nick:$chan)"
putloglev 2 * "$chan's slots: $mc_mp3voice(stat:$chan)"
putloglev 2 * "......"
 }
;# Slots information ; end
 if {(![isop $nick $chan]) && (![isvoice $nick $chan]) && ([botisop $chan])} {
  pushmode $chan +v $nick
  if {([info exists mp3autov(mainchan)]) && ([validchan $mp3autov(mainchan)])} {
   if {[string tolower $chan] == $mp3autov(mainchan)} {
    putserv "NOTICE $nick :[mp3autov:replace $mp3autov(0x001) "{%chan} {$chan}"]"
   } {
    if {([onchan $nick $mp3autov(mainchan)]) && (([isvoice $nick $mp3autov(mainchan)]) ||
        ([isop $nick $mp3autov(mainchan)]))} {
     putserv "NOTICE $nick :[mp3autov:replace $mp3autov(0x002) "{%chan} {$chan}"]"
    } {  
     putserv "NOTICE $nick :[mp3autov:replace $mp3autov(0x004) "{%chan} {$chan} %mainchan $mp3autov(mainchan)"]"
    }
   }
  } {
   putserv "NOTICE $nick :[mp3autov:replace $mp3autov(0x003) "{%chan} {$chan}"]"
  }
 }
# if {($mp3autov(topic)) && (([string match "* $chan *" $mp3autov(topic_chans)]) ||
#     ($mp3autov(topic_chans) == ""))} {}
 if {![info exists mp3autov(users:$chan)]} {
  set mp3autov(users:$chan) "$nick"
  mc:mp3:inter:+server $nick $chan
 } {
  if {![string match "* [mp3autov:filt $nick] *" " $mp3autov(users:$chan) "]} {
   set mp3autov(users:$chan) "$mp3autov(users:$chan) $nick"
   mc:mp3:inter:+server $nick $chan
  }
 };return 0
}

proc mp3autov:chk_topic {} {
 global mp3autov mp3topic botnick mc_mp3voice
 if {!$mp3autov(topic)} {return 0}
 if {$mp3autov(topic_chans) == ""} {
  if {$mp3autov(chans) == ""} {set mp3autov(!chans) " [string tolower [join [channels] " "]] "} {
   set mp3autov(!chans) $mp3autov(chans)
  }
  set mp3autov(!topic_chans) " [string tolower [join $mp3autov(!chans) " "]] "
 } {set mp3autov(!topic_chans) $mp3autov(topic_chans)}
 foreach chan $mp3autov(!topic_chans) {
  if {[info exists mp3autov(users:$chan)]} {
   set mp3autov(users:$chan) [join [lrange [split $mp3autov(users:$chan)] 0 e]]
  } {set mp3autov(users:$chan) ""}
  set mp3autov(!users:$chan) [join [split [join [lrange [lsort -ascii [mp3autov:filt $mp3autov(users:$chan)]] 0 e] $mp3autov(0x006)]]]
  if {$mp3autov(!users:$chan) == ""} {set buffer $mp3autov(0x005)} {
   set buffer $mp3autov(!users:$chan)
  }
  if {[info exists mp3topic([string tolower $chan])]} {
   set mp3autov(topic_) $mp3topic([string tolower $chan])
  } {set mp3autov(topic_) $mp3topic(default)}
  if {[info exists mc_mp3voice(stat:$chan)]} {
   set temp_replace "%slots [lindex $mc_mp3voice(stat:$chan) 1]"
   set temp_replace "$temp_replace %takenslots [lindex $mc_mp3voice(stat:$chan) 0]"
   set temp_replace "$temp_replace %que [lindex $mc_mp3voice(stat:$chan) 3]"
   set temp_replace "$temp_replace %takenque [lindex $mc_mp3voice(stat:$chan) 2]"
   set temp_replace "$temp_replace %cps [lindex $mc_mp3voice(stat:$chan) 4]"
   set temp_replace "$temp_replace %files [lindex $mc_mp3voice(stat:$chan) 5]"
   set temp_i [expr [lindex $mc_mp3voice(stat:$chan) 5]*$mp3autov(estfilesize)].0 
   set temp_size megs
   while {$temp_i >= 1000} {
    set temp_i [expr $temp_i/1000]
    if {$temp_size == "megs"} {set temp_size gigs} {
     if {$temp_size == "gigs"} {set temp_size teras}
    }
   }
   set temp_replace "$temp_replace %estfilesize {$temp_i $temp_size}"
   set temp_replace "$temp_replace %kps [expr [lindex $mc_mp3voice(stat:$chan) 4]/1000.0]"
   set temp_replace "$temp_replace %freeslots [expr [lindex $mc_mp3voice(stat:$chan) 1]-[lindex $mc_mp3voice(stat:$chan) 0]]"
   set temp_replace "$temp_replace %freeque [expr [lindex $mc_mp3voice(stat:$chan) 3]-[lindex $mc_mp3voice(stat:$chan) 2]]"
  } {
   set temp_replace "%slots n/a"
   set temp_replace "$temp_replace %takenslots n/a"
   set temp_replace "$temp_replace %que n/a"
   set temp_replace "$temp_replace %takenque n/a"
   set temp_replace "$temp_replace %cps n/a"
   set temp_replace "$temp_replace %files n/a"
   set temp_replace "$temp_replace %estfilesize n/a"
   set temp_replace "$temp_replace %kps n/a"
   set temp_replace "$temp_replace %freeslots n/a"
   set temp_replace "$temp_replace %freeque n/a"
  }
  set mp3autov(!topic_) [join [mp3autov:replace $mp3autov(topic_) "$temp_replace {%chan} {$chan} {%servers} {[mp3autov:filt $buffer]} %num [llength [split $mp3autov(!users:$chan)]]"]]
  if {[string length $mp3autov(!topic_)] > $mp3autov(chr_topic)} {
   set mp3autov(!topic_) "[string range $mp3autov(!topic_) 0 [expr $mp3autov(chr_topic)-4]]..."
  }
  if {([string tolower $mp3autov(!topic_)] != [string tolower [topic $chan]]) &&
      ([isop $botnick $chan])} {
   putserv "TOPIC $chan :$mp3autov(!topic_)"
  }
 }
 if {![string match "* mp3autov:chk_topic *" [timers]]} {
  timer $mp3autov(freq) "mp3autov:chk_topic"
 }
}

proc mp3autov:postchan {} {
 global mp3autov mp3postchan mp3topic mc_mp3voice
 if {!$mp3autov(postchan)} {return}
 set chans "" ; if {$mp3autov(postchans) == ""} {set chans [string tolower [channels]]} {
  set chans [string tolower $mp3autov(postchans)]
 }
 foreach chan $chans {
  if {[info exists mp3autov(users:$chan)]} {
   set mp3autov(users:$chan) [join [lrange [split $mp3autov(users:$chan)] 0 e]]
  } {set mp3autov(users:$chan) ""}
  set mp3autov(!users:$chan) [join [split [join [lrange [lsort -ascii [mp3autov:filt $mp3autov(users:$chan)]] 0 e] $mp3autov(0x006)]]]
  if {$mp3autov(!users:$chan) == ""} {set buffer $mp3autov(0x005)} {
   set buffer $mp3autov(!users:$chan)
  }
  if {[info exists mp3postchan([string tolower $chan])]} {
   set mp3autov(post_) $mp3postchan([string tolower $chan])
  } {set mp3autov(post_) $mp3postchan(default)}
  if {[info exists mc_mp3voice(stat:$chan)]} {
   set temp_replace "%slots [lindex $mc_mp3voice(stat:$chan) 1]"
   set temp_replace "$temp_replace %takenslots [lindex $mc_mp3voice(stat:$chan) 0]"
   set temp_replace "$temp_replace %que [lindex $mc_mp3voice(stat:$chan) 3]"
   set temp_replace "$temp_replace %takenque [lindex $mc_mp3voice(stat:$chan) 2]"
   set temp_replace "$temp_replace %cps [lindex $mc_mp3voice(stat:$chan) 4]"
   set temp_replace "$temp_replace %files [lindex $mc_mp3voice(stat:$chan) 5]"
   set temp_i [expr [lindex $mc_mp3voice(stat:$chan) 5]*$mp3autov(estfilesize)].0 
   set temp_size megs
   while {$temp_i >= 1000} {
    set temp_i [expr $temp_i/1000]
    if {$temp_size == "megs"} {set temp_size gigs} {
     if {$temp_size == "gigs"} {set temp_size teras}
    }
   }
   set temp_replace "$temp_replace %estfilesize {$temp_i $temp_size}"
   set temp_replace "$temp_replace %kps [expr [lindex $mc_mp3voice(stat:$chan) 4]/1000.0]"
   set temp_replace "$temp_replace %freeslots [expr [lindex $mc_mp3voice(stat:$chan) 1]-[lindex $mc_mp3voice(stat:$chan) 0]]"
   set temp_replace "$temp_replace %freeque [expr [lindex $mc_mp3voice(stat:$chan) 3]-[lindex $mc_mp3voice(stat:$chan) 2]]"
  } {
   set temp_replace "%slots n/a"
   set temp_replace "$temp_replace %takenslots n/a"
   set temp_replace "$temp_replace %que n/a"
   set temp_replace "$temp_replace %takenque n/a"
   set temp_replace "$temp_replace %cps n/a"
   set temp_replace "$temp_replace %files n/a"
   set temp_replace "$temp_replace %estfilesize n/a"
   set temp_replace "$temp_replace %kps n/a"
   set temp_replace "$temp_replace %freeslots n/a"
   set temp_replace "$temp_replace %freeque n/a"
  }
  foreach post [split $mp3autov(post_) \n] {
   set post [join [mp3autov:replace $post "$temp_replace {%chan} {$chan} {%servers} {[mp3autov:filt $buffer]} %num [llength [split $mp3autov(!users:$chan)]]"]]
   if {$post != ""} {puthelp "PRIVMSG $chan :$post"}
  }
 }
 if {![string match *mp3autov:postchan* [timers]]} {
  timer $mp3autov(postchan) mp3autov:postchan
 }
}
if {($mp3autov(postchan)) && (![string match *mp3autov:postchan* [timers]])} {
 timer $mp3autov(postchan) mp3autov:postchan
}

proc mp3autov:part {args} {
 set nick [lindex [split $args] 0]
 set uhost [lindex [split $args] 1]
 set hand [lindex [split $args] 2]
 set chan [lindex [split $args] 3]
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 if {[info exists mp3autov(users:$chan)]} {
  if {[string match "* [mp3autov:filt $nick] *" " $mp3autov(users:$chan) "]} {
   set mp3autov(users:$chan) [join [mp3autov:lremove "[split $mp3autov(users:$chan)]" "[split $nick]"]]
  }
 }
 if {[info exists mc_mp3voice(stat:$nick:$chan)]} {
  if {[info exists mc_mp3voice(stat:$chan)]} {
putloglev 2 * "PART, $nick (before): $mc_mp3voice(stat:$nick:$chan)"
putloglev 2 * "PART, $chan (before): $mc_mp3voice(stat:$chan)"
   set temp_slots [expr [lindex $mc_mp3voice(stat:$nick:$chan) 1]*-1]
   set temp_takenslots [expr [lindex $mc_mp3voice(stat:$nick:$chan) 0]*-1]
   set temp_que [expr [lindex $mc_mp3voice(stat:$nick:$chan) 3]*-1]
   set temp_takenque [expr [lindex $mc_mp3voice(stat:$nick:$chan) 2]*-1]
   set temp_cps [expr [lindex $mc_mp3voice(stat:$nick:$chan) 4]*-1]
   set temp_files [expr [lindex $mc_mp3voice(stat:$nick:$chan) 5]*-1]
   set temp_cslots [expr [lindex $mc_mp3voice(stat:$chan) 1]+$temp_slots]
   set temp_ctakenslots [expr [lindex $mc_mp3voice(stat:$chan) 0]+$temp_takenslots]
   set temp_cque [expr [lindex $mc_mp3voice(stat:$chan) 3]+$temp_que]
   set temp_ctakenque [expr [lindex $mc_mp3voice(stat:$chan) 2]+$temp_takenque]
   set temp_ccps [expr [lindex $mc_mp3voice(stat:$chan) 4]+$temp_cps]
   set temp_cfiles [expr [lindex $mc_mp3voice(stat:$chan) 5]+$temp_files]
   set mc_mp3voice(stat:$chan) "$temp_ctakenslots $temp_cslots $temp_ctakenque $temp_cque $temp_ccps $temp_cfiles"
putloglev 2 * "PART, $chan (after): $mc_mp3voice(stat:$chan)"
  } ; unset mc_mp3voice(stat:$nick:$chan)
 }
}

proc mp3autov:sign {nick uhost hand chan reason} {
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 if {[info exists mp3autov(users:$chan)]} {
  if {[string match "* [mp3autov:filt $nick] *" " $mp3autov(users:$chan) "]} {
   set mp3autov(users:$chan) [join [mp3autov:lremove "[split $mp3autov(users:$chan)]" "[split $nick]"]]
  }
 }
 if {[info exists mc_mp3voice(stat:$nick:$chan)]} {
  if {[info exists mc_mp3voice(stat:$chan)]} {
putloglev 2 * "SIGN, $nick (before): $mc_mp3voice(stat:$nick:$chan)"
putloglev 2 * "SIGN, $chan (before): $mc_mp3voice(stat:$chan)"
   set temp_slots [expr [lindex $mc_mp3voice(stat:$nick:$chan) 1]*-1]
   set temp_takenslots [expr [lindex $mc_mp3voice(stat:$nick:$chan) 0]*-1]
   set temp_que [expr [lindex $mc_mp3voice(stat:$nick:$chan) 3]*-1]
   set temp_takenque [expr [lindex $mc_mp3voice(stat:$nick:$chan) 2]*-1]
   set temp_cps [expr [lindex $mc_mp3voice(stat:$nick:$chan) 4]*-1]
   set temp_files [expr [lindex $mc_mp3voice(stat:$nick:$chan) 5]*-1]
   set temp_cslots [expr [lindex $mc_mp3voice(stat:$chan) 1]+$temp_slots]
   set temp_ctakenslots [expr [lindex $mc_mp3voice(stat:$chan) 0]+$temp_takenslots]
   set temp_cque [expr [lindex $mc_mp3voice(stat:$chan) 3]+$temp_que]
   set temp_ctakenque [expr [lindex $mc_mp3voice(stat:$chan) 2]+$temp_takenque]
   set temp_ccps [expr [lindex $mc_mp3voice(stat:$chan) 4]+$temp_cps]
   set temp_cfiles [expr [lindex $mc_mp3voice(stat:$chan) 5]+$temp_files]
   set mc_mp3voice(stat:$chan) "$temp_ctakenslots $temp_cslots $temp_ctakenque $temp_cque $temp_ccps $temp_cfiles"
putloglev 2 * "SIGN, $chan (after): $mc_mp3voice(stat:$chan)"
  } ; unset mc_mp3voice(stat:$nick:$chan)
 }
}

proc mp3autov:nick {nick uhost hand chan newnick} {
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 if {[info exists mp3autov(users:$chan)]} {
  if {[string match "* [mp3autov:filt $nick] *" " $mp3autov(users:$chan) "]} {
   set mp3autov(users:$chan) [join [mp3autov:lremove "[split $mp3autov(users:$chan)]" "[split $nick]"]]
   mc:mp3voice $newnick $uhost $hand $chan MP3 {NICK PROC CALL}
  }
 }
 if {[info exists mc_mp3voice(stat:$nick:$chan)]} {
putloglev 2 * "NICK, $chan : $mc_mp3voice(stat:$chan)"
putloglev 2 * "NICK, $nick : $mc_mp3voice(stat:$nick:$chan)"
  set mc_mp3voice(stat:$newnick:$chan) $mc_mp3voice(stat:$nick:$chan)
  unset mc_mp3voice(stat:$nick:$chan)
putloglev 2 * "NICK, $newnick : $mc_mp3voice(stat:$newnick:$chan)"
 }
}

proc mp3autov:kick {nick uhost hand chan knick reason} {
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 mp3autov:part $knick [getchanhost $knick $chan] [nick2hand $knick $chan] $chan
}

proc mp3autov:join {nick uhost hand chan} {
 global mp3autov botnick mc_mp3voice ; set chan [string tolower $chan]
 if {$nick != $botnick} {return 0} ; set chan [string tolower $chan]
 catch {unset mp3autov(users:$chan)}
 catch {unset mc_mp3voice(stat:$chan)}
 foreach array [array names mc_mp3voice] {
  if {[string match "stat:*:$chan" $array]} {unset mc_mp3voice($array)}
 }
}

proc mc:mp3:inter:+server {nick chan} {
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 if {[string match "*mc:mp3:inter:-server $nick $chan*" [timers]]} {
  foreach timer [timers] {
   if {[string match "*mc:mp3:inter:-server [mp3autov:filt $nick] $chan*" $timer]} {killtimer [lindex $timer 2]}
  }
 } ; timer $mp3autov(servexr) "mc:mp3:inter:-server [split $nick] $chan"
}

proc mc:mp3:inter:-server {nick chan} {
 global mp3autov mc_mp3voice ; set chan [string tolower $chan]
 if {$mp3autov(servexp-v) && ![matchattr [nick2hand $nick $chan] +v|+v $chan]} {
  pushmode $chan -v $nick
 } ; mp3autov:part $nick [getchanhost $nick $chan] [nick2hand $nick $chan] $chan
}

proc mp3autov:lremove {list data} {
 set new_list ""
 foreach item $data {
  while {[lsearch -exact $list $item] > "-1"} {
   set list [lreplace $list [lsearch -exact $list $item] [lsearch -exact $list $item]]
  }
 } ; return $list
}

proc mp3autov:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

proc mp3autov:filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

bind ctcp -|- MP3 mc:mp3voice
bind raw -|- PRIVMSG mc:mp3voice:pre
proc mc:mp3voice:pre {from keyword args} {
 set args [join $args]
 if {[lindex [split $args] 1] != ":SLOTS"} {return 0}
 set nick [lindex [split $from !] 0]
 set uhost [string range $from [expr [string first ! $from]+1] e]
 set chan [lindex [split $args] 0]
 set hand [nick2hand $nick $chan]
 set args [join [split [string trimright [lrange [split $args] 2 e] ""] " "]]
 mc:mp3voice "$nick" $uhost $hand $chan SLOTS $args
 return 0
}
bind part -|- * mp3autov:part
bind sign -|- * mp3autov:sign
bind nick -|- * mp3autov:nick
bind kick -|- * mp3autov:kick
bind join -|- * mp3autov:join
bind dcc o|o +mp3server mp3autov:dcc:+mp3server
bind dcc o|o -mp3server mp3autov:dcc:-mp3server
bind pub o|o +mp3server mp3autov:pub:+mp3server
bind pub o|o -mp3server mp3autov:pub:-mp3server

if {$mp3autov(svs:enabled)} {
 if {($mp3autov(svs:check) > "23") || ($mp3autov(svs:check) < "0")} {set mp3autov(svs:check) 00}
 if {[string length $mp3autov(svs:check)] == "1"} {set mp3autov(svs:check) 0$mp3autov(svs:check)}
 if {$mp3autov(svs:stableonly)} {
  set mp3autov(svs:script) [string range $mp3autov(svs:script) 0 [expr [string length $mp3autov(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mp3autov(svs:oldcheck) * * *" mc:mp3:svs:time}
 set mp3autov(svs:oldcheck) $mp3autov(svs:check)
 bind time - "00 $mp3autov(svs:check) * * *" mc:mp3:svs:time
 proc mc:mp3:svs:time {min hour day month year} {
  global mp3autov
  catch {control [connect [lindex $mp3autov(svs:server) 0] [lindex $mp3autov(svs:server) 1]] mc:mp3:svs:interface}
 }
}
proc mc:mp3:svs:interface {idx args} {
 global mp3autov;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mp3autov(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mp3autov(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mp3autov(svs:script) 1]} {
    set note [mc:mp3:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:mp3:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:mp3:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mp3autov(version)}"]
    set note [mc:mp3:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:mp3:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:mp3:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:mp3:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mp3autov(svs:notify) ",;"]] {
     set outnote [mc:mp3:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mp3autov(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mp3autov(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:mp3:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "MP3 Voice $mp3autov(version) by MC_8 loaded."