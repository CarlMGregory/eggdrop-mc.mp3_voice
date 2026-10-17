# Beta version, to be v2.0
##
# MP3 Voice v2.0
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
# TCL Mailing list - http://mc.purehype.net:81/maillist/
##

##
# This script will auto voice a user for sharing an mp3.  The script
# detects mp3 sharing via ctcp mp3 and ctcp slots (spr type serving).  
# Also has topic and channel posting features.
#
# This script also has mc.mp3reporter built into it, actually, it was 
# developed in this script first, and later made into a seperate script 
# as well for those who wanted to report mp3's to 
# http://www.purehype.net:2001/mp3/ but not have this script loaded.
#
# If you have stumbled upon this script while looking for a tcl script 
# for eggdrop that will voice users if there running a server 
# (something like an fserve or ftp post), this is not the script for
# you.  This script is only for spr type serving.  But, your not out of 
# luck.  You can use my '(de)Voice Command' (mc.(de)voice-cmd.tcl) 
# script for that purpose.  You can find that script on my SVS Website 
# advertisment above, in the header of this script.
##

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v2.0 (03.14.02)
#  MC_8 - rodolfo ramos - SVS information incorrect.
#                         Bugzilla bug: 59
#  MC_8 - ^OmeN^        - Fixed '[mc:mp3:ctcp]: syntax error in 
#                         expression "1025098+"'.
#                         Bugzilla bug: 46
#  MC_8 -               - Fixed '[mc:mp3:leave]: no such channel 
#                         record'.
#                         Bugzilla bug: 45
#  MC_8 -               - Wasn't keeping record of current servers nor 
#                         channel stats.
#                         Bugzilla bug: 39
#  MC_8 -               - Added error catching system.
#  MC_8 -               - Rewrote the entire script, more effecent.  In 
#                         doing this, I removed alot of old crap such 
#                         as mainchan witch was just a lame spam 
#                         feature.  In doing that, changed up the 
#                         language settings.  Rewrote the http report 
#                         function for better effecency.  Removed alot 
#                         of crap settings.  Basically, there is too 
#                         much stuff to say here, consider the script
#                         nothing like it was before -- for the good.
#  MC_8 -               - Upgraded SVS from v1.2 to v2.0.
#
# v1.10.1 (10.29.01)
#  MC_8 - - Fixed 'Tcl error [mc:mp3voice]: error flushing "sockXX": 
#           broken pipe'.
#
# v1.10 (8.30.01)
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: wrong # 
#                         args: should be "split string ?splitChars?"'.
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: syntax 
#                         error in expression "19996+4,978"'.  Seems 
#                         there is some lame ass SpR wanna be script
#                         out there making things difficult.
#  MC_8 -               - Added mc_mp3(http:report) option.
#
# v1.9.1 (06.30.01)
#  MC_8 - - mc_mp3(servexr) was expiring the server after that time of 
#           being voiced rather than last known mp3 sharing activity, 
#           fixed.
#
# v1.9 (03.11.01)
#  MC_8 -      - Added SVS v1.2
#  MC_8 - unk^ - Fixed:  The %servers replacment wasn't building a 
#                list of mp3 servers if the topic feature wasn't on, 
#                but yet the post feature was.
#
# v1.8 (09.19.00)
#  MC_8 - - Added %estfilesize (estimated size of combined files).
#
# v1.7.1 (08.22.00)
#  MC_8 - - Fixed, "msg already queued. skipping: PRIVMSG #channel :" 
#           anoyance.
#  MC_8 - - Borg script just has to be different, *sigh*.  Made this 
#           script adapt (funny hu) to the borg script.
#           This fixes: Tcl error [mc:mp3voice:pre]: syntax error in 
#                       expression "0+408 (1,652.20 mb)"
#           The borg script has this " " in the SLOTS files, no... it's 
#           not a chr 32 (space), it's a chr 160... damn it, I almost 
#           pulled my hair out figuring that one out.
#
# v1.7 (08.14.00)
#  MC_8 -         - Works with the new part bind format (eggdrop1.5.3 
#                   and up will need this)
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc:mp3:inter:-server 
#                   user #channel': wrong # args: should be 
#                   "getchanhost nickname channel"" 
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc_mp3:chk_topic': bad 
#                   switch "-dic": must be -ascii, -integer, -real, 
#                   -increasing -decreasing, or -command"
#  MC_8 - riddler - Fixed, "Tcl error [mc:mp3voice:pre]: wrong # args: 
#                   should be "nick2hand nick channel""
#  MC_8 -         - Added;
#                     %slots (Combined, avilable slots)
#                     %takenslots (Combined, free slots)
#                     %que (Combined, que taken)
#                     %takenque (Combined, avilable que slots)
#                     %cps (Combined, cps)
#                     %files (Combined, files avilable)
#                     %kps (Combined, k/s)
#                     %freeslots (Combined, send slots free)
#                     %freeque (Combined, que slots free)
#  MC_8 -         - Added server idle time-out feature.
#
# v1.6 (04.08.00)
#  MC_8 -        - Added timed channel posting option.
#  MC_8 - gigman - Fixed `Tcl error [mc:mp3voice]: invalid command name 
#                  "notice"'
#
# v1.5.1 (03.28.00)
#  MC_8 - - Minor problem, faulty readout on %num for the topic.  If no 
#           servers it said there were one, thinking =none= was a 
#           server.
#  MC_8 - - Added 0x005 and 0x006 to the language section.
#
# v1.5 (03.18.00)
#  MC_8 - - Removed the commands (useless, I don't see why anyone would 
#           use them... more trouble to code than it's worth)
#  MC_8 - - Made an easy to change language system (just for 
#           customizable reasons).
#  MC_8 - - Removed the /invite crap associated with mainchan (That's 
#           to close to spam).
#  MC_8 - - Added ability to have different topics for different rooms 
#           (more customizable).
#  MC_8 - - Added topic check frequency veriable (it was set at 5 min's 
#           core coded in prev versions).
#  MC_8 - - Servers such as SPR doesn't send RFC complent CTCP SLOT's, 
#           made a work around to compensate.
#  MC_8 - - Was fuxen up on special charatered nicks AGAIN... Fixed 
#           AGAIN (hopefully the last time).
#  MC_8 - - Removed its dependency on moretools.
#
# v1.4 (11-22-99)
#  MC_8 -       - Wasn't doing topic over run correctly (mc_mp3
#                 (chr_topic)).
#  MC_8 - Shawn - Even if mc_mp3(topic) was 0, would do topic anyway, 
#                 fixed that!
#
# v1.3b (10-11-99)
#  MC_8 - - Fixed, error'd out on []{} nicks => topic checking.
#        `- Fixed topic garble, on part/quit/kick was removing nick and 
#           seperating spaces for servers.
#  MC_8 - - Now resets user database upon self join.
#  MC_8 - - Fixed, was eating up the CPU usage (ping timeout, shell 
#           lock up, 50-80% CPU usage).  Was a bug in moretools 1.1.4.
#  MC_8 - - Added mc_mp3(mainchan) feature.
#
# v1.3a (10-09-99)
#  MC_8 - - Added a kick bind... wasn't clearing mp3server out of topic 
#           when he was kicked.
#
# v1.3 (??.??.99)
#  MC_8 - - Fixed minor bug, when no servers, it started giving out 
#           errors and not working anymore.
#
# v1.0 - 1.2 (??.??.99)
#  MC_8 - - Inital Release.
##

##
# COMMANDS (dcc)
##
# chanset <#channel> <-/+>mc.mp3voice
#   Setting this enables (+) or disables (-) the script for the 
#   particular channel.
#
# chanset <#channel> mc.mp3voice.update_topic <number>
#   How often, in min's, do you want to update the topic of the 
#   specific channel?  Setting this to 0 disables this function.
#
# chanset <#channel> mc.mp3voice.update_public <number>
#   How often, in min's, do you want to update the specific channel?
#   Updating the channel consists of a public PRIVMSG.  Setting this to 
#   0 disables this function.
##

##
# Settings
##

# How long, in min's, of not recieving signs of a user serving do you 
# want to wait before removing the user from the active servers list?  
# Keep in mind, serving is justified by channel CTCP SLOTS and CTCP 
# MP3's.  Set this to 0 to never remove the user from the active 
# servers list.
set mc_mp3(expire_server) 30

# Set this to the topic message you want to set.  In relation to the 
# update_topic dcc chanset.  Each different channel can have it's own 
# personal topic set here, or you can just use 'default''s topic.  Set 
# this veriable in this fasion:
#   set mc_mp3(:topic:<'#'channel|'default'>) "<The topic for the channel.>"
# Replacment veriables:
#  %channel           - The channels name.
#  %servers           - The list of active servers for the channel.
#  %n_servers         - Number of active servers in the channel.
#  %total_send_slots  - Overall available send slots for the channel.
#  %taken_send_slots  - Overall number of send slots that are currently 
#                       in use.
#  %free_send_slots   - Overall number of send slots free for use.
#  %total_queue_slots - Overall avilable que slots for the channel.
#  %taken_queue_slots - Overall number of que slots that are currently 
#                       in use.
#  %free_queue_slots  - Overall number of que slots free for use.
#  %cps               - Overall highest recorded characters per second.
#  %kps               - Overall highest recorded kilobytes per second.
#  %files             - Overall number of files currently offered to 
#                       the channel.
#  %estfilesize       - Estamated size of overall files currently 
#                       offered to the channel.
set mc_mp3(:topic:#mp34free) "8,2%channel4(8%n_servers 11servers4/8%files 11files4~8%estfilesize4)11 Current Servers: 8%servers11."
set mc_mp3(:topic:default) "%channel is rocking with %n_servers active server(s): %servers"

# How many characters will the server allow in the topic?  If you set 
# this too long, and you've chosen to have this script auto update the 
# topic, the topic will be updated once every minute regardless if it 
# needs it or not -- so please either under set it or set it correctly.
# If you don't know what this should be set to, do this;
#   1) Join a temp channel on the irc server of your choise.
#   2) Set the topic to a really long topic.
#   3) Once the topic is set, you should see that it got cut off.  If 
#      it did not get cut off, then set the topic even longer and 
#      longer untill it finally does get cut off by the server.
#      Q: What's 'cut off' mean?
#      A: You set the topic to "Hello everyone!", but after you set it, 
#         it only shows "Hello ev".  It got cut off by the server.
#   4) Count the number of characters in the cut off topic, That's the 
#      topic limit for that server.
# Here are some I already know, as of 8:08am 02-07-02;
#   DALnet   = 307
#   EFnet    = 120
#   IRCnet   = 160
#   Undernet = 160
set mc_mp3(topiclen) 160

# Set this to the public message you want to post.  In relation to the 
# update_public dcc chanset.  Each different channel can have it's own 
# personal post set here, or you can just use 'default''s topic.  Set 
# this veriable in this fasion:
#   set mc_mp3(:public:<'#'channel|'default'>) {
#    <The public post here, line 1>
#    <The public post here, line 2>
#   }
# As you can see, it can be multi lined.  Seperate each new line with a 
# new line.
# Replacment veriables:
#  %channel           - The channels name.
#  %servers           - The list of active servers for the channel.
#  %n_servers         - Number of active servers in the channel.
#  %total_send_slots  - Overall available send slots for the channel.
#  %taken_send_slots  - Overall number of send slots that are currently 
#                       in use.
#  %free_send_slots   - Overall number of send slots free for use.
#  %total_queue_slots - Overall avilable que slots for the channel.
#  %taken_queue_slots - Overall number of que slots that are currently 
#                       in use.
#  %free_queue_slots  - Overall number of que slots free for use.
#  %cps               - Overall highest recorded characters per second.
#  %kps               - Overall highest recorded kilobytes per second.
#  %files             - Overall number of files currently offered to 
#                       the channel.
#  %estfilesize       - Estamated size of overall files currently 
#                       offered to the channel.
set mc_mp3(:public:#mp34free) {
12,2 1011 Welcome to 8%channel11, we have8 %n_servers 11detected servers online to serve you:8 %servers11. 1012 
12,2 1011 Combined channel status: 4(8%files11files4~8%estfilesize4) (8%free_send_slots11 Free Send Slots4)11-4(8%free_queue_slots11 Free Que Slots4)11->4[(8%taken_send_slots4/8%total_send_slots4)11 Slots Taken 4(8%taken_queue_slots4/8%total_queue_slots4)11 Ques Taken4] [11Highest Cps Record: 8%kpsk/s4] 111012 
}
set mc_mp3(:public:default) {
12,2 1011 Welcome to 8%channel11, we have8 %n_servers 11detected servers online to serve you:8 %servers11. 1012 
}

# The %estfilesize replacment veriable used in public and topic updates 
# is calculated by the number of files offered to the channel times the 
# number you set below.  What's the average size, in megabytes, of the 
# files being offered in your channels?
set mc_mp3(estfilesize) 8

# [0=no/1=yes] Do you want to report mp3s being offered in the channel, 
# via CTCP MP3, to a web bassed mp3 search engine?  
#
# I coded an mp3 search engine, it can be utalized at 
# http://www.purehype.net:2001/mp3/.  Please keep in mind, the server 
# may or may not be online as of right now (the time your reading this, 
# 1 year later or 10 years later), so check it out before enabling.
set mc_mp3(http:report) 1

# What server do you want to report mp3's to?  As of right now, there 
# is only 1 server that supports this, and that's only because I made 
# it.  This isn't folloing any sorta standards so the idea is origional 
# therefor no one else will prolly run a server other than 
# www.purehype.net unless they ask me for the coding.  This goes in 
# direct relation to mc_mp3(http:report).
set mc_mp3(http:server) "www.purehype.net"

# What port is this web based mp3 search engine on?  www.purehype.net's 
# is currently on 2001.  This goes in direct relation to 
# mc_mp3(http:report).
set mc_mp3(http:port) "2001"


## MC SVS (Script Version Service) v2.0 ##
# [0=no/1=yes] Do you want the bot to connection to MC_8's SVS to see
# if there are newer versions of this script avilable?  It will only
# tell you -- It's up to you to get the newest version (I decided not
# to auto update the code, there may be new features in the newest
# script that may require your attention).
set mc_mp3(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_mp3(svs:check) 0   ;#This is at Midnight
#  set mc_mp3(svs:check) 5   ;#This is at 5am
#  set mc_mp3(svs:check) 13  ;#This is at 1pm
#  set mc_mp3(svs:check) 23  ;#This is at 11pm
set mc_mp3(svs:check) 3

# Upon finding a newer version of this script, who do you want this
# script to send a note to telling them of this newer version? If more
# than 1 user is to be notified, seperate each user with a ' ' (space).
set mc_mp3(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or
# just stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_mp3(svs:stableonly) 0


##
# Language
##

# Trigged upon a user detected serving. 1st word either NOTICE or 
# PRIVMSG
#  Using veriables: %chan
set mc_mp3(0x001) "NOTICE 12 You have been voiced in %chan for sharing your mp3's, thank you."

# What do you want to split the %servers with?
#  Ie.  Server1, Server2, Server3
#       The ", " is the split.
set mc_mp3(0x002) "11, 8"

# If there are not servers, %servers return this.
set mc_mp3(0x003) "=none="


##
# Edit no further, tcl coding below.
##

# [programmer setting] What's the GET URI for the web based mp3 search 
# engine?  This goes in direct relation to mc_mp3(http:report).
set mc_mp3(http:location) "/mp3/index.cgi"

# The query string that should be passed, action=add is already 
# prepended.
set mc_mp3(http:query) "mp3=%mp3&nick=%nick&chan=%chan&server=%server"

#Script:mc_mp3

set mc_mp3(script)      "MP3 Voice"
set mc_mp3(version)     "v2.0"
set mc_mp3(svs:script)  "mp3voice"
set mc_mp3(svs:version) "002000000000"
set mc_mp3(svs:server)  "mc.purehype.net"
set mc_mp3(svs:port)    "81"
set mc_mp3(svs:get)     "/"
set mc_mp3(svs:query)   "svs=$mc_mp3(svs:script)&version=$mc_mp3(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_mp3(script) $mc_mp3(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_mp3(script) $mc_mp3(version)  will not work with eggdrop $version."
 putlog "$mc_mp3(script) $mc_mp3(version)  not loaded."
 return 1
}

setudef flag mc.mp3voice
setudef int mc.mp3voice.update_topic
setudef int mc.mp3voice.update_public

proc mc:mp3:error {bindproc error {arg ""}} {
 global mc_mp3 version lastbind
 putlog "Error in script $mc_mp3(script) $mc_mp3(version)."
 putlog "        Last bind: $lastbind"
 putlog "        Procedure: $bindproc"
 putlog "             Args: $arg"
 putlog "  Eggdrop version: $version"
 putlog "      TCL version: [info tclversion]"
 putlog "*** Please tell MC_8 about this BUG!  Visit        "
 putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
 putlog "*** Please include the next line in the bug report."
 error $error
}

proc mc:mp3:errchk {command arg} {
 if {[catch {eval $command $arg} return]} {
  mc:mp3:error $command $return $arg; return 0
 }; return $return
}

foreach array [array names mc_mp3] {
 if {([regexp -- ^:topic: $array]) && ([regexp -- {[A-Z]} $array])} {
  set mc_mp3([string tolower $array]) $mc_mp3($array)
  unset mc_mp3($array)
 }
}

bind pub - \001MP3 mc:mp3:pub:ctcp:mp3
proc mc:mp3:pub:ctcp:mp3 {nick uhost hand chan arg} {mc:mp3:ctcp $nick $uhost $hand $chan MP3 $arg}

bind pub - \001SLOTS mc:mp3:pub:ctcp:slots
proc mc:mp3:pub:ctcp:slots {nick uhost hand chan arg} {mc:mp3:ctcp $nick $uhost $hand $chan SLOTS $arg}

bind ctcp - MP3 mc:mp3:ctcp
bind ctcp - SLOTS mc:mp3:ctcp

proc mc:mp3:ctcp {nick uhost hand chan key arg} {
 return [mc:mp3:errchk mc:mp3:ctcp_ [list $nick $uhost $hand $chan $key $arg]]
}
proc mc:mp3:ctcp_ {nick uhost hand chan key arg} {
 global mc_mp3
 if {(![mc:mp3:validchan $chan]) || (![mc:mp3:chanflag $chan mc.mp3voice])} {return 0}
 set lchan [string tolower $chan]; set lnick [string tolower $nick]
 set temp(:setting:botisop) [botisop $chan]
 set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]
 set temp(:setting:update_public) [mc:mp3:chanint $chan mc.mp3voice.update_public]
 switch -- [string toupper $key] {
  "SLOTS" {
   if {(($temp(:setting:botisop)) && ($temp(:setting:update_topic))) || ($temp(:setting:update_public))} {
    set arg [split [set temp(arg) $arg] " "]
    set arg "[lrange $arg 0 5] [list [mc:mp3:replace [lindex [split [lindex $arg 6] [format %c 160]] 0] [list , ""]]]"
    set temp(:arg:0) [lindex $arg 0]
    set temp(:arg:1) [lindex $arg 1]
    set temp(:arg:3) [lindex $arg 3]
    set temp(:arg:4) [lindex $arg 4]
    set temp(:arg:5) [lindex $arg 5]
    set temp(:arg:6) [lindex $arg 6]
    set temp(:arg:list) "$temp(:arg:0) $temp(:arg:1) $temp(:arg:3) $temp(:arg:4) $temp(:arg:5) $temp(:arg:6)"
    if {($temp(:arg:6) == "") || ($temp(:arg:0) < $temp(:arg:1)) || ($temp(:arg:3) > $temp(:arg:4)) ||
        ([regexp -- {[^0-9 ]} $temp(:arg:list)])} {
     putlog "$mc_mp3(script):  Invalid CTCP SLOTS post from $nick on $chan:  $temp(arg)"
     return 0
    }
    set array_chan [list list $lchan]
    set array_nick [list list $lchan $lnick]
    if {![info exists mc_mp3($array_chan)]} {set mc_mp3($array_chan) $temp(:arg:list)} \
    elseif {[info exists mc_mp3($array_nick)]} {
     if {$mc_mp3($array_nick) != $temp(:arg:list)} {
      set mc_mp3($array_chan) [list [expr [lindex $mc_mp3($array_chan) 0]+($temp(:arg:0)-[lindex $mc_mp3($array_nick) 0])]\
                                    [expr [lindex $mc_mp3($array_chan) 1]+($temp(:arg:1)-[lindex $mc_mp3($array_nick) 1])]\
                                    [expr [lindex $mc_mp3($array_chan) 2]+($temp(:arg:3)-[lindex $mc_mp3($array_nick) 2])]\
                                    [expr [lindex $mc_mp3($array_chan) 3]+($temp(:arg:4)-[lindex $mc_mp3($array_nick) 3])]\
                                    [expr [lindex $mc_mp3($array_chan) 4]+($temp(:arg:5)-[lindex $mc_mp3($array_nick) 4])]\
                                    [expr [lindex $mc_mp3($array_chan) 5]+($temp(:arg:6)-[lindex $mc_mp3($array_nick) 5])]]
     }
    } else {
     set mc_mp3($array_chan) [list [expr [lindex $mc_mp3($array_chan) 0]+$temp(:arg:0)]\
                                   [expr [lindex $mc_mp3($array_chan) 1]+$temp(:arg:1)]\
                                   [expr [lindex $mc_mp3($array_chan) 2]+$temp(:arg:3)]\
                                   [expr [lindex $mc_mp3($array_chan) 3]+$temp(:arg:4)]\
                                   [expr [lindex $mc_mp3($array_chan) 4]+$temp(:arg:5)]\
                                   [expr [lindex $mc_mp3($array_chan) 5]+$temp(:arg:6)]]
    }; set mc_mp3($array_nick) $temp(:arg:list)
   }
  }
  "MP3" {mc:mp3:http_report_addqueue $nick $chan $arg}
 }
 if {$temp(:setting:botisop)} {
  if {(![isvoice $nick $chan]) && (![isop $nick $chan])} {
   if {[matchattr $hand q|q $chan]} {
    putlog "$mc_mp3(script):  Cannot voice $nick (hand: $hand) for serving in $chan, user has the 'q' flag."
   } else {pushmode $chan +v $nick}
   set method [lindex [split $mc_mp3(0x001) " "] 0]
   set msg [mc:mp3:replace [join [lrange [split $mc_mp3(0x001) " "] 1 end] " "] [list %chan $chan]]
   if {[regexp -- {^(NOTICE|PRIVMSG)$} [string toupper $method]]} {putserv "$method $nick :$msg"}
  }
  if {$mc_mp3(expire_server)} {
   set temp(:setting:timers) [timers]
   if {[set temp(temp) [lsearch -glob $temp(:setting:timers) "* [mc:mp3:filt [list [list mc:mp3:del_server $nick $chan]]] timer*"]] != "-1"} {
    killtimer [lindex [lindex $temp(:setting:timers) $temp(temp)] 2]
   }; timer $mc_mp3(expire_server) [list mc:mp3:del_server $nick $chan]
  }
 }
 if {(($temp(:setting:update_topic)) && ($temp(:setting:botisop))) || ($temp(:setting:update_public))} {
  set array_serv [list servers $lchan]
  if {![info exists mc_mp3($array_serv)]} {set mc_mp3($array_serv) [list $nick]} \
  elseif {[lsearch -exact $mc_mp3($array_serv) $nick] == "-1"} {lappend mc_mp3($array_serv) $nick}
 }; return 0
}

bind part - * mc:mp3:leave
bind sign - * mc:mp3:leave
proc mc:mp3:leave {nick uhost hand chan arg} {mc:mp3:del_server $nick $chan 1}

bind nick - * mc:mp3:nick
proc mc:mp3:nick {nick uhost hand chan newnick} {
 return [mc:mp3:errchk mc:mp3:nick_ [list $nick $uhost $hand $chan $newnick]]
}
proc mc:mp3:nick_ {nick uhost hand chan newnick} {
 global mc_mp3
 set lchan [string tolower $chan]
 set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]
 if {(![mc:mp3:chanflag $chan mc.mp3voice]) ||
     ((((![botisop $chan]) && ($temp(:setting:update_topic))) ||
     (!$temp(:setting:update_topic))) &&
     (![mc:mp3:chanint $chan mc.mp3voice.update_public]))} {
  set temp(temp) [mc:mp3:filt [list $lchan]]
  array unset mc_mp3 "* $temp(temp) *"
  array unset mc_mp3 "* $temp(temp)"
  return 0
 }
 set array_serv [list servers $lchan]
 set array_chan [list list $lchan]
 set old_array_nick [list list $lchan [string tolower $nick]]
 set new_array_nick [list list $lchan [string tolower $newnick]]
 if {([info exists mc_mp3($array_serv)]) && ([set temp(i) [lsearch -exact $mc_mp3($array_serv) $nick]] != "-1")} {
  set mc_mp3($array_serv) [lreplace $mc_mp3($array_serv) $temp(i) $temp(i) $newnick]
  if {[info exists mc_mp3($old_array_nick)]} {
   # Doing it in this manner incase the nick change is just a casing change
   # in the users nick.
   set temp(temp) $mc_mp3($old_array_nick)
   unset mc_mp3($old_array_nick)
   set mc_mp3($new_array_nick) $temp(temp)
  }
  if {$mc_mp3(expire_server)} {
   set temp(:setting:timers) [timers]
   if {[set temp(temp) [lsearch -glob $temp(:setting:timers) "* [mc:mp3:filt [list [list mc:mp3:del_server $nick $chan]]] timer*"]] != "-1"} {
    set temp(timer) [lindex $temp(:setting:timers) $temp(temp)]
    set temp(time) [lindex $temp(timer) 0]
    killtimer [lindex $temp(timer) 2]
    timer $temp(time) [list mc:mp3:del_server $newnick $chan]
   }
  }
 }
}

bind kick - * mc:mp3:kick
proc mc:mp3:kick {nick uhost hand chan target reason} {mc:mp3:del_server $target $chan 1}

bind join - * mc:mp3:join

proc mc:mp3:join {nick uhost hand chan} {mc:mp3:reset_chan_if_isbotnick $nick $chan}

bind mode - "% -o" mc:mp3:deop
proc mc:mp3:deop {nick uhost hand chan mc victim} {mc:mp3:reset_chan_if_isbotnick $victim $chan}

proc mc:mp3:reset_chan_if_isbotnick {nick chan} {
 return [mc:mp3:errchk mc:mp3:reset_chan_if_isbotnick_ [list $nick $chan]]
}
proc mc:mp3:reset_chan_if_isbotnick_ {nick chan} {
 global mc_mp3 botnick
 if {[string tolower $nick] != [string tolower $botnick]} {return 0}
 set temp(temp) [mc:mp3:filt [list [string tolower $chan]]]
 array unset mc_mp3 "* $temp(temp) *"
 array unset mc_mp3 "* $temp(temp)"
}

proc mc:mp3:del_server {nick chan {leave 0}} {
 return [mc:mp3:errchk mc:mp3:del_server_ [list $nick $chan $leave]]
}
proc mc:mp3:del_server_ {nick chan {leave 0}} {
 global mc_mp3 botnick
 set lchan [string tolower $chan]
 if {(![mc:mp3:validchan $chan]) || (([string tolower $nick] == [string tolower $botnick]) && ($leave)) ||
     (![mc:mp3:chanflag $chan mc.mp3voice]) ||
     ((((![botisop $chan]) && ([mc:mp3:chanint $chan mc.mp3voice.update_topic])) ||
     (![mc:mp3:chanint $chan mc.mp3voice.update_topic])) &&
     (![mc:mp3:chanint $chan mc.mp3voice.update_public]))} {
  set temp(temp) [mc:mp3:filt [list $lchan]]
  array unset mc_mp3 "* $temp(temp) *"
  array unset mc_mp3 "* $temp(temp)"
  return 0
 }
 set array_serv [list servers $lchan]
 set array_chan [list list $lchan]
 set array_nick [list list $lchan [string tolower $nick]]
 if {([info exists mc_mp3($array_serv)]) && ([set temp(i) [lsearch -exact $mc_mp3($array_serv) $nick]] != "-1")} {
  set mc_mp3($array_serv) [lreplace $mc_mp3($array_serv) $temp(i) $temp(i)]
  if {([info exists mc_mp3($array_chan)]) && ([info exists mc_mp3($array_nick)])} {
   set mc_mp3($array_chan) [list [expr [lindex $mc_mp3($array_chan) 0]-[lindex $mc_mp3($array_nick) 0]]\
                                 [expr [lindex $mc_mp3($array_chan) 1]-[lindex $mc_mp3($array_nick) 1]]\
                                 [expr [lindex $mc_mp3($array_chan) 2]-[lindex $mc_mp3($array_nick) 2]]\
                                 [expr [lindex $mc_mp3($array_chan) 3]-[lindex $mc_mp3($array_nick) 3]]\
                                 [expr [lindex $mc_mp3($array_chan) 4]-[lindex $mc_mp3($array_nick) 4]]\
                                 [expr [lindex $mc_mp3($array_chan) 5]-[lindex $mc_mp3($array_nick) 5]]]
   unset mc_mp3($array_nick)
  }
  set hand [nick2hand $nick $chan]
  if {([isvoice $nick $chan]) && (![isop $nick $chan]) &&
      !(([matchattr $hand g|g $chan]) || (([matchattr $hand v|v $chan]) && ([mc:mp3:chanflag $chan autovoice])))} {
   pushmode $chan -v $nick
  }
 }
}

# v1.0+mc.mp3voice
# Special chanflag version for this script, since mp3 servers
# spit out so much bandwidth... this version cuts 30k microseconds
# off the cpu.  The chanflag from mc.moretools is still good and
# will be recomended rather than this one.
proc mc:mp3:chanflag {channel flag} {
 if {[lsearch -exact [string tolower [channel info $channel]] +[string tolower $flag]] == "-1"} {return 0}; return 1
}

# v1.0+mc.mp3voice
# Special chanint version for this script, since mp3 servers
# spit out so much bandwidth... this version cuts 1k-11k microseconds
# off the cpu.  The chanint from mc.moretools is still good and
# will be recomended rather than this one.
proc mc:mp3:chanint {channel int} {
 set temp(chaninfo) [string tolower [channel info $channel]]
 if {[set temp(i) [lsearch -glob $temp(chaninfo) "[mc:mp3:filt [string tolower $int]] *"]] == "-1"} {return 0}
 return [lindex [lindex $temp(chaninfo) $temp(i)] 1]
}

# v1.1
proc mc:mp3:replace {text subs} {
 if {![catch {string map -nocase $subs $text} output]} {return $output}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])} [lindex $subs $i] {\\\1} temp(temp)
  regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
 }; return $text
}

# v1.0
# This is 1000 microseconds faster than core 'validchan'.
proc mc:mp3:validchan {chan} {
 if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == "-1"} {return 0}; return 1
}

# v2.0+mc.mp3voice
# This is a special filter for this script, use the
# one from mc.moretools rather than this one.
proc mc:mp3:filt {text} {regsub -all -- {([\\\{\}\[\]\"\*\?])} $text {\\\1} text; return $text}

bind time - * mc:mp3:time
proc mc:mp3:time {{args ""}} {
 return [mc:mp3:errchk mc:mp3:time_ [list $args]]
}
proc mc:mp3:time_ {{args ""}} {
 foreach chan [string tolower [channels]] {
  if {![mc:mp3:chanflag $chan mc.mp3voice]} {continue}
  set temp(timers) [timers]
  if {([botisop $chan]) && ([set temp(time) [mc:mp3:chanint $chan mc.mp3voice.update_topic]])} {
   set temp(i) 1
   if {[set temp(timer_index) [lsearch -glob $temp(timers) "* [mc:mp3:filt [list [list mc:mp3:update topic $chan]]] timer*"]] != "-1"} {
    set temp(timer) [lindex $temp(timers) $temp(timer_index)]
    if {[lindex $temp(timer) 0] > $temp(time)} {killtimer [lindex $temp(timer) 2]} else {set temp(i) 0}
   }; if {$temp(i)} {timer $temp(time) [list mc:mp3:update topic $chan]}
  }
  if {[set temp(time) [mc:mp3:chanint $chan mc.mp3voice.update_public]]} {
   set temp(i) 1
   if {[set temp(timer_index) [lsearch -glob $temp(timers) "* [mc:mp3:filt [list [list mc:mp3:update public $chan]]] timer*"]] != "-1"} {
    set temp(timer) [lindex $temp(timers) $temp(timer_index)]
    if {[lindex $temp(timer) 0] > $temp(time)} {killtimer [lindex $temp(timer) 2]} else {set temp(i) 0}
   }; if {$temp(i)} {timer $temp(time) [list mc:mp3:update public $chan]}
  }
 }
}; mc:mp3:time

proc mc:mp3:update {type chan} {
 return [mc:mp3:errchk mc:mp3:update_ [list $type $chan]]
}
proc mc:mp3:update_ {type chan} {
 global mc_mp3
 set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]
 set temp(:setting:update_public) [mc:mp3:chanint $chan mc.mp3voice.update_public]
 if {(![mc:mp3:validchan $chan]) || (![mc:mp3:chanflag $chan mc.mp3voice]) ||
     (($type == "topic") && (((![botisop $chan]) && ($temp(:setting:update_topic))) || (!$temp(:setting:update_topic)))) ||
     (($type == "public") && (!$temp(:setting:update_public)))} {return 0}
 timer $temp(:setting:update_$type) [list mc:mp3:update $type $chan]
 set lchan [string tolower $chan]
 set array_serv [list servers $lchan]
 set array_chan [list list $lchan]
 if {![info exists mc_mp3($array_serv)]} {set mc_mp3($array_serv) ""}
 if {![info exists mc_mp3($array_chan)]} {set mc_mp3($array_chan) [list 0 0 0 0 0 0]}
 if {$mc_mp3($array_serv) == ""} {set temp(servers) $mc_mp3(0x003)} \
 else {set temp(servers) [join [lsort -dictionary $mc_mp3($array_serv)] $mc_mp3(0x002)]}
 set temp(:setting:array_chan:0) [lindex $mc_mp3($array_chan) 0]
 set temp(:setting:array_chan:1) [lindex $mc_mp3($array_chan) 1]
 set temp(:setting:array_chan:2) [lindex $mc_mp3($array_chan) 2]
 set temp(:setting:array_chan:3) [lindex $mc_mp3($array_chan) 3]
 set temp(:setting:array_chan:4) [lindex $mc_mp3($array_chan) 4]
 set temp(:setting:array_chan:5) [lindex $mc_mp3($array_chan) 5]
 set temp(estfilesize) [expr $temp(:setting:array_chan:5)*$mc_mp3(estfilesize)] 
 set temp(size) megs
 while {($temp(estfilesize) >= 1024) && ($temp(size) != "terabytes")} {
  set temp(estfilesize) [expr $temp(estfilesize)/1024]
  switch -- $temp(size) {
   megs {set temp(size) gigs}
   gigs {set temp(size) terabytes}
  }
 }; append temp(estfilesize) " $temp(size)"
 set temp(replace) [list %channel           $chan \
                         %servers           $temp(servers) \
                         %n_servers         [llength $mc_mp3($array_serv)] \
                         %total_send_slots  $temp(:setting:array_chan:0) \
                         %taken_send_slots  [expr $temp(:setting:array_chan:0)-$temp(:setting:array_chan:1)] \
                         %free_send_slots   $temp(:setting:array_chan:1) \
                         %total_queue_slots $temp(:setting:array_chan:3) \
                         %taken_queue_slots $temp(:setting:array_chan:2) \
                         %free_queue_slots  [expr $temp(:setting:array_chan:3)-$temp(:setting:array_chan:2)] \
                         %cps               $temp(:setting:array_chan:4) \
                         %kps               [expr $temp(:setting:array_chan:4)/1024] \
                         %files             $temp(:setting:array_chan:5) \
                         %estfilesize       $temp(estfilesize)]

 if {[info exists mc_mp3(:$type:$lchan)]} {set temp(output) $mc_mp3(:$type:$lchan)} \
 elseif {[info exists mc_mp3(:$type:default)]} {set temp(output) $mc_mp3(:$type:default)} \
 else {
  putlog "$mc_mp3(script):  Error trying to update $chan, no $type record found."
  return 0
 }; set temp(output) [mc:mp3:replace $temp(output) $temp(replace)]
 switch -- $type {
  topic {
   if {[string length $temp(output)] > $mc_mp3(topiclen)} {
    set temp(output) [string range $temp(output) 0 [expr $mc_mp3(topiclen)-4]]...
   }; if {$temp(output) != [topic $chan]} {puthelp "TOPIC $chan :$temp(output)"}
  }
  public {
   foreach temp(buffer) [split $temp(output) \n] {
    if {$temp(buffer) != ""} {puthelp "PRIVMSG $chan :$temp(buffer)"}
   }
  }
 }
}

proc mc:mp3:http_report_addqueue {nick chan mp3} {
 return [mc:mp3:errchk mc:mp3:http_report_addqueue_ [list $nick $chan $mp3]]
}
proc mc:mp3:http_report_addqueue_ {nick chan mp3} {
 global mc_mp3 server; if {$mc_mp3(http:report)} {lappend mc_mp3(::http_report::) [list $nick $chan $mp3 $server]}
}

bind time - "25 *" mc:mp3:http_report
proc mc:mp3:http_report {{args ""}} {
 return [mc:mp3:errchk mc:mp3:http_report_ [list $args]]
}
proc mc:mp3:http_report_ {{args ""}} {
 global mc_mp3
 if {(!$mc_mp3(http:report)) || (![info exists mc_mp3(::http_report::)]) || ($mc_mp3(::http_report::) == "")} {return 0}
 if {[catch {socket -async $mc_mp3(http:server) $mc_mp3(http:port)} sid]} {
  putlog "$mc_mp3(script):  HTTP Reporting Error;  $sid"
  return 0
 }
 fconfigure $sid -blocking 0 -buffering line
 set query [list action=add]
 foreach entry $mc_mp3(::http_report::) {
  set nick [lindex $entry 0]; set chan [lindex $entry 1]; set mp3 [lindex $entry 2]; set server [lindex $entry 3]
  set temp(query) [mc:mp3:replace $mc_mp3(http:query) [list %mp3    [mc:mp3:httpd_encode $mp3] \
                                                            %nick   [mc:mp3:httpd_encode $nick] \
                                                            %chan   [mc:mp3:httpd_encode $chan] \
                                                            %server [mc:mp3:httpd_encode $server]]]
  lappend query $temp(query)
 }; set query [join $query &]
 puts $sid "POST $mc_mp3(http:location) HTTP/1.0\
          \nHost: $mc_mp3(http:server)\
          \nContent-Length: [string length $query]\n\n${query}"
 flush $sid; close $sid
 set length [llength $mc_mp3(::http_report::)]
 if {$length == "1"} {set s ""} else {set s s}
 putlog "$mc_mp3(script):  HTTP Reporting; reported $length file$s to http://$mc_mp3(http:server):$mc_mp3(http:port)$mc_mp3(http:location)"
 set mc_mp3(::http_report::) ""
}

# v1.1
proc mc:mp3:httpd_encode {text} {
 regsub -all {\%} $text "%25" text; regsub -all { } $text "+" text
 set i [string length $text]
 while {([regexp {[^a-zA-Z0-9+%]} $text toh]) && ($i > 0)} {
  incr i -1; scan "$toh" %c dec
  regsub -all -- {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])} $toh {\\\1} toh
  regsub -all -- $toh $text "%[format %X $dec]" text
 }; return $text
}

## SVS v2.0
if {(![info exists mc_mp3(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_mp3(svs:enabled)])} {set mc_mp3(svs:enabled) 0}
if {(![info exists mc_mp3(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_mp3(svs:check)])} {set mc_mp3(svs:check) 0}
if {![info exists mc_mp3(svs:notify)]} {set mc_mp3(svs:notify) $owner}
if {(![info exists mc_mp3(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_mp3(svs:stableonly)])} {set mc_mp3(svs:stableonly) 0}
foreach bind [binds mc:mp3:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:mp3:svs:time] {rename $command ""}
if {$mc_mp3(svs:enabled)} {
 if {($mc_mp3(svs:check) > "23") || ($mc_mp3(svs:check) < "0")} {set mc_mp3(svs:check) 00}
 if {[string length $mc_mp3(svs:check)] == "1"} {set mc_mp3(svs:check) 0$mc_mp3(svs:check)}
 bind time - "00 $mc_mp3(svs:check) *" mc:mp3:svs:time
 proc mc:mp3:svs:time {{args ""}} {
  global mc_mp3
  if {[catch {socket -async $mc_mp3(svs:server) $mc_mp3(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_mp3(svs:script)/$mc_mp3(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:mp3:svs:interface $sid timeout"]
  fileevent $sid readable "mc:mp3:svs:interface $sid $tout"
  puts $sid "GET $mc_mp3(svs:get)?$mc_mp3(svs:query) HTTP/1.0\
           \nHost: $mc_mp3(svs:server)\n"
  flush $sid
 }
}
proc mc:mp3:svs:interface {sid tout} {
 global mc_mp3
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_mp3(svs:script)/$mc_mp3(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_mp3(svs:script)} {
     putlog "SVS Error\[$mc_mp3(svs:script)/$mc_mp3(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break   
    }
    if {$mc_mp3(svs:stableonly)} {
     set temp [string range $mc_mp3(svs:version) 0 8]999
    } else {set temp [string range $mc_mp3(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_mp3(version) note
     foreach to [split $mc_mp3(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_mp3(svs:script)/$mc_mp3(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_mp3(svs:script)/$mc_mp3(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_mp3(script) $mc_mp3(version) by MC_8 loaded."


##
# Misc information, for the coder.
##

# SPR SLOTS
# 2 1 NOW 6 999 80800 13304
# {Total send slots} {Avail send slots} {next send} {Taken queue slots} {Total queue slots} {CPS Record} {Total files}
#        0                       1            2                3                 4                 5          6
# List format
# {Total send slots} {Avail send slots} {Taken queue slots} {Total queue slots} {CPS Record} {Total files}
#        0                    1                  2                  3                4             5
