##
# MP3 Voice v3.0.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug?  http://mc.purehype.net/bugzilla/
##

##
# This script will auto voice a user for sharing an mp3, or any other file type
# you specify in the configuration of this script (bellow).  The script detects
# file sharing via SPR's unwritten standard of 'ctcp <file_type>' and 'ctcp
# slots'.  Also has topic and channel posting features to show various
# information about channel statistics based on the servers.
#
# If you have stumbled upon this script while looking for a tcl script for
# eggdrop that will voice users if there running a server (something like an 
# fserve or ftp post), this is not the script for you.  This script is only for
# spr type serving. But, your not out of luck.  You can use my 'Bad Words'
# (mc.bad_words.tcl) script for that purpose.  You can find that script on 
# http://mc.purehype.net/.
##

##
# Commands
##
# Public:
#   +mp3server <nick>
#     This will add the server's nick to the list of servers, and voice as well.
#     You must be a valid op, registered in the bots, to use this command.
#
#   -mp3server <nick>
#     This will remove the server's nick to the list of servers, and de-voice as
#     well.  You must be a valid op, registered in the bots, to use this
#     command.
#
# DCC:
#   chanset <channel> <-/+>mc.mp3voice
#     Setting this enables (+) or disables (-) the script for the particular 
#     channel.
#
#   chanset <channel> mc.mp3voice.update_public <number>
#     How often, in min's, do you want to update the specific channel?
#     Updating the channel consists of a public PRIVMSG.  Setting this to 0
#     disables this function.
#
#   chanset <channel> mc.mp3voice.public_text <text>
#     Set this to the public message you want to post for the specific channel.
#     This is posted upon an update_public (see dcc chanset 
#     mc.mp3voice.update_public above).  You can have multiple lines, split
#     each line by a \n.
#     Replacement variables:
#       %channel           - The channels name.
#       %servers           - The list of active servers for the channel.
#       %n_servers         - Number of active servers in the channel.
#       %total_send_slots  - Overall available send slots for the channel.
#       %taken_send_slots  - Overall number of send slots that are currently in
#                            use.
#       %free_send_slots   - Overall number of send slots free for use.
#       %total_queue_slots - Overall available queue slots for the channel.
#       %taken_queue_slots - Overall number of queue slots that are currently in 
#                            use.
#       %free_queue_slots  - Overall number of queue slots free for use.
#       %cps               - Overall highest recorded characters per second.
#       %kbps              - Overall highest recorded kilobytes per second.
#       %files             - Overall number of files currently offered to the 
#                            channel.
#       %estfilesize       - Estimated size of overall files currently offered
#                            to the channel.
#     Example:
#       .chanset #mp34free mc.mp3voice.public_text Welcome to %channel, we have %n_servers detected servers online to serve you: %servers.\nCombined channel status: (%files files~%estfilesize) (%free_send_slots Free Send Slots)-(%free_queue_slots Free queue Slots)->[(%taken_send_slots/%total_send_slots) Slots Taken (%taken_queue_slots/%total_queue_slots) Queues Taken] [Highest Cps Record: %kbpsk/s]
#
#   chanset <channel> mc.mp3voice.update_topic <number>
#     How often, in min's, do you want to update the topic of the specific
#     channel? Setting this to 0 disables this function.
# 
#   chanset <channel> mc.mp3voice.topic_text <topic>
#     Set this to the topic you want for the specific channel.  This topic is
#     set upon an update_topic (see dcc chanset mc.mp3voice.update_topic above).
#     Replacement variables:
#       %channel           - The channels name.
#       %servers           - The list of active servers for the channel.
#       %n_servers         - Number of active servers in the channel.
#       %total_send_slots  - Overall available send slots for the channel.
#       %taken_send_slots  - Overall number of send slots that are currently in
#                            use.
#       %free_send_slots   - Overall number of send slots free for use.
#       %total_queue_slots - Overall available queue slots for the channel.
#       %taken_queue_slots - Overall number of queue slots that are currently in
#                            use.
#       %free_queue_slots  - Overall number of queue slots free for use.
#       %cps               - Overall highest recorded characters per second.
#       %kbps              - Overall highest recorded kilobytes per second.
#       %files             - Overall number of files currently offered to the 
#                            channel.
#       %estfilesize       - Estimated size of overall files currently offered
#                            to the channel.
#     Example:
#       .chanset #mp34free mc.mp3voice.topic_text %channel (%n_servers servers/%files files~%estfilesize) Current Servers: %servers.
##

##
# Configuration
##
#

# How long, in min's, of not receiving signs of a user serving do you want to
# wait before removing the user from the active servers list?  Keep in mind,
# serving is justified by channel CTCP SLOTS and CTCP MP3's.  Set this to 0 to
# never remove the user from the active servers list.
set mc_mp3(:config:expire_server) 30

# How many characters will the server allow in the topic?  If you set this too
# long, and you've chosen to have this script auto update the topic, the topic
# will be updated once every x minutes you specified regardless if it needs it
# or not -- so please either under set it or set it correctly.  If you don't
# know what this should be set to, do this;
#   1) Join a temp channel on the irc server of your choice.
#   2) Set the topic to a really long topic.
#   3) Once the topic is set, you should see that it got cut off.  If it did
#      not get cut off, then set the topic even longer and longer until it
#      finally does get cut off by the server.
#      Q: What's 'cut off' mean?
#      A: You set the topic to "Hello everyone!", but after you set it, it only
#         show "Hello ev".  It got cut off by the server.
#   4) Count the number of characters in the cut off topic, That's the topic
#      limit for that server.
# Here are some I already know, as of 8:08am 02-07-02;
#   DALnet   = 307
#   EFnet    = 120
#   IRCnet   = 160
#   Undernet = 160
set mc_mp3(:config:topiclen) 160

# The %estfilesize replacement veritable used in public and topic updates is
# calculate by the number of files offered to the channel times the number you
# set below. What's the average size, in megabytes, of the files being offered
# in your channels?  No, the script cannot calculate this information on it's
# own, current ctcp slots format does not give up enough information to do so.
# Example; By setting this to 8, the average size of all files being served is
#          to be 8mb.
set mc_mp3(:config:estfilesize) 8

# What different file types are offered in your channel?  Separate each file
# type with a space.
set mc_mp3(:config:file_types) "mp2 mp3 mp4 mpg mpeg asf avi"


## SVS Client (Script Version Service) v4.0.2 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?
set mc_mp3(:config:svs:enable) 1

#
##

##
# Language
##
#

# Triggered upon a user detected serving and not voiced nor opped and the user
# doesn't have the 'q' flag. The first word should either be NOTICE or PRIVMSG,
# depending on how you want the message sent to the user.
# Replacement variables:
#   %channel == The channel user if serving in.
set mc_mp3(0x001) "NOTICE You have been voiced in %channel for sharing your mp3's, thank you."

# %servers is a replacement variable in the public_text and topic_text. How do
# you want the servers split up?
# Example:
#   - Set this to ", " and servers will be in such a format as
#     Server1, Server2, ServerN
#   - Set this to " - " and server will be in such a format as
#     Server1 - Server2 - ServerN
#   - Set this to "" and servers will be in such a format as
#     Server1Server2ServerN
set mc_mp3(0x002) ", "

# %servers is a replacement variable in the public_text and topic_text. If there
# are no servers, what do you want it to say in %servers' place?
# Example:
#   Set this to "*none*" and if no servers, %servers will be replaced with
#   *none*.
set mc_mp3(0x003) "=none="

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

#Script:mc_mp3

catch {unset temp}
set mc_mp3(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_mp3 :config:*] {
  lappend mc_mp3(info:vars) [list $temp(name) $temp(value)]
}
set mc_mp3(info:loc) [info script]
array set mc_mp3 [list \
  script                 "MP3 Voice" \
  version                "v3.0.1" \
  svs:script             "mp3voice" \
  svs:version            "003000001000" \
  svs:client_version     "v4.0.2" \
  svs:client_svs_version "004000002000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "81" \
  svs:get                "/index.tcl"]
set mc_mp3(svs:query)    "svs=$mc_mp3(svs:script)&"
append mc_mp3(svs:query) "version=$mc_mp3(svs:version)&"
append mc_mp3(svs:query) "svs_version=$mc_mp3(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_mp3(script) $mc_mp3(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  return 1
}

setudef flag mc.mp3voice
setudef int mc.mp3voice.update_public
setudef str mc.mp3voice.public_text
setudef int mc.mp3voice.update_topic
setudef str mc.mp3voice.topic_text

# Error system, v3.0
proc mc:mp3:error {command error arg} {
  global mc_mp3 version lastbind errorInfo
  putloglev o * "Error in script $mc_mp3(script) $mc_mp3(version)."
  putloglev o * "    Error System: v3.0"
  putloglev o * \
    "       Last Bind: [expr {[info exists lastbind]?$lastbind:"-NULL-"}]"
  putloglev o * "         Command: $command"
  putloglev o * "       Arguments: $arg"
  putloglev o * "       Error Msg: $error"
  putloglev o * \
    "    Egg. Version: [expr {[info exists version]?$version:"-NULL-"}]"
  putloglev o * "     TCL Version: [info tclversion]"
  putloglev o * "  TCL Patchlevel: [info patchlevel]"
  putloglev o * "*** Please submit this bug so MC_8 can fix it.  Visit"
  putloglev o * \
    "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
  putloglev o * \
    "*** Please include ALL info. in the bug report, including the next(s)."
  error $errorInfo
}

proc mc:mp3:errchk {command arg} {
  if {![catch {eval $command $arg} return]} {return $return}
  mc:mp3:error $command $return $arg
  return 0
}
# ^

bind pub o|o +mp3server mc:mp3:pub:+mp3server
proc mc:mp3:pub:+mp3server {nick uhost handle channel text} {
  return [mc:mp3:errchk mc:mp3:pub:+mp3server_ \
    [list $nick $uhost $handle $channel $text]]
}
proc mc:mp3:pub:+mp3server_ {nick uhost handle channel text} {
  global mc_mp3
  set l_channel [string tolower $channel]
  set tnick [lindex [split $text] 0]
  
  if {![channel get $channel mc.mp3voice]} {return 0}
  
  if {![onchan $tnick $channel]} {
    putserv "NOTICE $nick :Failed; $tnick not on $channel."
    return 0
  }
  
  set tnick_new ""
  foreach item [chanlist $channel] {
    if {[string tolower $item] == [string tolower $tnick]} {
      set tnick_new $item
      break
    }
  }; set tnick $tnick_new
  
  if {$tnick == ""} {
    putserv "NOTICE $nick :Failed; $tnick not found on $channel."
    return 0
  }
  
  set handle [nick2hand $tnick]
  
  set temp() ""
  if {([botisop $channel] && [channel get $channel mc.mp3voice.update_topic]) ||
      [channel get $channel mc.mp3voice.update_public]} {
    set array [list list $l_channel $tnick]
    if {![info exists mc_mp3($array)]} {
      set mc_mp3($array) [list 0 0 0 0 0 0]
      set temp() "(but I did added him/her from the servers list)"
    } else {
      putserv "NOTICE $nick :User is already added as a server."
      return 0
    }
  }
  if {![botisop $channel]} {
    putserv "NOTICE $nick :Cannot voice $tnick, I'm not opped."
  } elseif {[isvoice $tnick $channel]} {
    putserv "NOTICE $nick :$tnick is already voiced."
  } elseif {[isop $tnick $channel]} {
    putserv "NOTICE $nick :$tnick is opped, he can voice himself."
  } elseif {[matchattr $handle q|q $channel]} {
    putserv \
      "NOTICE $nick :$tnick (handle $handle) has the q flag, cannot voice."
  } else {
    pushmode $channel +v $tnick
    set temp() [split $mc_mp3(0x001)]
    set method [string toupper [lindex $temp() 0]]
    set msg [mc:mp3:replace [join [lrange $temp() 1 end]] \
      [list %channel $channel]]
    if {[regexp -- {^(NOTICE|PRIVMSG)$} $method]} {
      putserv "$method $tnick :$msg"
    }
  }
  if {$mc_mp3(:config:expire_server)} {
    set temp(command) [list mc:mp3:del_server $tnick $l_channel]
    foreach timer [timers] {
      if {[lindex $timer 1] == $temp(command)} {
        killtimer [lindex $timer 2]
      }
    }
    timer $mc_mp3(:config:expire_server) $temp(command)
  }
}

bind pub o|o -mp3server mc:mp3:pub:-mp3server
proc mc:mp3:pub:-mp3server {nick uhost handle channel text} {
  return [mc:mp3:errchk mc:mp3:pub:-mp3server_ \
    [list $nick $uhost $handle $channel $text]]
}
proc mc:mp3:pub:-mp3server_ {nick uhost handle channel text} {
  global mc_mp3
  
  if {![channel get $channel mc.mp3voice]} {return 0}
    
  set l_channel [string tolower $channel]
  set tnick [lindex [split $text] 0]
  set l_tnick [string tolower $tnick]
  
  set found 0
  foreach name [array names mc_mp3] {
    set name_nick [lindex $name 2]
    if {([lindex $name 0] == "list") &&
        ([lindex $name 1] == $l_channel) &&
        ([string tolower $name_nick] == $l_tnick)} {
      unset mc_mp3($name)
      
      set temp(command) [list mc:mp3:del_server $name_nick $l_channel]

      foreach timer [timers] {
        if {[lindex $timer 1] == $temp(command)} {
          killtimer [lindex $timer 2]
        }
      }
      
      set found 1
    }
  }
  if {!$found} {
    putserv "NOTICE $nick :$tnick not found in servers list for $channel."
    return 0
  }
  
  set handle [nick2hand $tnick]
  set temp() "(but I did remove him/her from the servers list)"
  if {![botisop $channel]} {
    putserv "NOTICE $nick :Cannot devoice, I am not opped."
  } elseif {![onchan $tnick $channel]} {
    putserv "NOTICE $nick :$tnick isn't on the channel, cannot devoice $temp()."
  } elseif {![isvoice $tnick $channel]} {
    putserv "NOTICE $nick :$tnick isn't voiced, cannot devoice $temp()."
  } elseif {[isop $tnick $channel]} {
    putserv "NOTICE $nick :$tnick is an op, will not devoice $temp()."
  } elseif {[matchattr $handle gv|gv $channel]} {
    set temp(2) "$tnick (handle $handle) has either the g or v flag"
    putserv "NOTICE $nick :$temp(2), will not devoice $temp()."
  } else {
    pushmode $channel -v $tnick
  }
}

foreach bind "[binds mc:mp3:pub:ctcp:file] [binds mc:mp3:pub:ctcp:mp3]" {
  foreach {temp(type) temp(flag) temp(command) temp() temp(proc)} $bind break
  unbind $temp(type) $temp(flag) $temp(command) $temp(proc)
}
foreach file_type [split [string toupper $mc_mp3(:config:file_types)]] {
  bind pub - \001$file_type mc:mp3:pub:ctcp:file
}
proc mc:mp3:pub:ctcp:file {nick uhost handle channel text} {
  return [mc:mp3:errchk mc:mp3:pub:ctcp:file_ \
    [list $nick $uhost $handle $channel $text]]
}
proc mc:mp3:pub:ctcp:file_ {nick uhost handle channel text} {
  regsub -- {\001$} $text "" file
  mc:mp3:ctcp $nick $uhost $handle $channel file $file
}

bind pub - \001SLOTS mc:mp3:pub:ctcp:slots
proc mc:mp3:pub:ctcp:slots {nick uhost handle channel text} {
  return [mc:mp3:errchk mc:mp3:pub:ctcp:slots_ \
    [list $nick $uhost $handle $channel $text]]
}
proc mc:mp3:pub:ctcp:slots_ {nick uhost handle channel text} {
  regsub -- {\001$} $text "" text
  mc:mp3:ctcp $nick $uhost $handle $channel SLOTS $text
}

foreach bind [binds mc:mp3:ctcp] {
  foreach {temp(type) temp(flag) temp(command) temp() temp(proc)} $bind break
  unbind $temp(type) $temp(flag) $temp(command) $temp(proc)
}
foreach file_type [split [string toupper "$mc_mp3(:config:file_types) SLOTS"]] {
  bind ctcp - $file_type mc:mp3:ctcp
}

proc mc:mp3:ctcp {nick uhost handle channel key text} {
  return [mc:mp3:errchk mc:mp3:ctcp_ \
    [list $nick $uhost $handle $channel $key $text]]
}
proc mc:mp3:ctcp_ {nick uhost handle channel key text} {
  global mc_mp3
  
  if {![validchan $channel] ||
      ![channel get $channel mc.mp3voice] ||
      ![onchan $nick $channel] ||
      ![botonchan $channel]} {
    return 0
  }
  
  set file_types [split [string toupper $mc_mp3(:config:file_types)]]
  if {[lsearch -exact $file_types $key] > "-1"} {set key "file"}
  set l_channel [string tolower $channel]

  set temp(:cache:botisop) [botisop $channel]
  set temp(:cache:update_topic) [channel get $channel mc.mp3voice.update_topic]
  set temp(:cache:update_public) \
    [channel get $channel mc.mp3voice.update_public]
  
  switch -- [string toupper $key] {
    
    "SLOTS" {
      if {($temp(:cache:botisop) && $temp(:cache:update_topic)) ||
          $temp(:cache:update_public)} {

        set temp(text) [split $text]
        set temp(text:new) [lrange $temp(text) 0 5]
        set temp() [split [lindex $temp(text) 6] [format %c 160]]
        lappend temp(text:new) [mc:mp3:replace [lindex $temp() 0] [list , ""]]
        set temp(text) $temp(text:new)

        set temp(text:0) [lindex $temp(text) 0] ;# Total send slots
        set temp(text:1) [lindex $temp(text) 1] ;# Avail send slots
        set temp(text:3) [lindex $temp(text) 3] ;# Taken queue slots
        set temp(text:4) [lindex $temp(text) 4] ;# Total queue slots
        set temp(text:5) [lindex $temp(text) 5] ;# CPS Record
        set temp(text:6) [lindex $temp(text) 6] ;# Total files

        if {$temp(text:6) == ""} {set temp(text:6) 0}

        set temp(text:list) [list $temp(text:0) $temp(text:1) $temp(text:3) \
          $temp(text:4) $temp(text:5) $temp(text:6)]

        if {($temp(text:0) < $temp(text:1)) ||
            ($temp(text:3) > $temp(text:4)) ||
            [regexp -- {[^0-9 ]} [join $temp(text:list)]]} {
          set temp() "Non standard CTCP SLOTS post from"
          putloglev d * "$mc_mp3(script): $temp() $nick on $channel: $text"
          return 0
        }

        set mc_mp3([list list $l_channel $nick]) $temp(text:list)
      }
    }
    
    default {
      set array [list list $l_channel $nick]
      if {![info exists mc_mp3($array)]} {
        set mc_mp3($array) [list 0 0 0 0 0 0]
      }
    }
    
  }
  if {$temp(:cache:botisop)} {
    if {![isvoice $nick $channel] && ![isop $nick $channel]} {
      if {[matchattr $handle q|q $channel]} {
        set temp() "Cannot voice $nick (hand: $handle) for serving in $channel"
        putloglev o * "$mc_mp3(script): $temp(), user has the 'q' flag."
      } else {
        pushmode $channel +v $nick
        set temp() [split $mc_mp3(0x001)]
        set method [string toupper [lindex $temp() 0]]
        set msg [mc:mp3:replace [join [lrange $temp() 1 end]] \
          [list %channel $channel]]
        if {[regexp -- {^(NOTICE|PRIVMSG)$} $method]} {
          putserv "$method $nick :$msg"
        }
      }
    }
    if {$mc_mp3(:config:expire_server)} {
      set temp(command) [list mc:mp3:del_server $nick $l_channel]
      foreach timer [timers] {
        if {[lindex $timer 1] == $temp(command)} {
          killtimer [lindex $timer 2]
        }
      }

      timer $mc_mp3(:config:expire_server) $temp(command)
    }
  }
  return 0
}

bind part - * mc:mp3:leave
bind sign - * mc:mp3:leave
proc mc:mp3:leave {nick uhost handle channel text} {
  return [mc:mp3:errchk mc:mp3:leave_ \
    [list $nick $uhost $handle $channel $text]]
}
proc mc:mp3:leave_ {nick uhost handle channel text} {
  mc:mp3:del_server $nick $channel
}

bind nick - * mc:mp3:nick
proc mc:mp3:nick {nick uhost handle channel newnick} {
  return [mc:mp3:errchk mc:mp3:nick_ \
    [list $nick $uhost $handle $channel $newnick]]
}
proc mc:mp3:nick_ {nick uhost handle channel newnick} {
  global mc_mp3
  
  if {![validchan $channel] || ($nick == $newnick)} {return}
  
  set l_channel [string tolower $channel]
  set array [list list $l_channel $nick]
  
  if {[info exists mc_mp3($array)]} {
    set new_array [list list $l_channel $newnick]
    set mc_mp3($new_array) $mc_mp3($array)
    unset mc_mp3($array)
    
    if {$mc_mp3(:config:expire_server)} {
      set temp(command) [list mc:mp3:del_server $nick $l_channel]
      set temp(new_command) [list mc:mp3:del_server $newnick $l_channel]
      
      set found 0
      foreach timer [timers] {
        if {[lindex $timer 1] == $temp(command)} {
          killtimer [lindex $timer 2]
          if {!$found} {
            timer [lindex $timer 0] $temp(new_command)
          } else {set found 1}
        }
      }
    }
  }
}

bind kick - * mc:mp3:kick
proc mc:mp3:kick {nick uhost handle channel target reason} {
  return [mc:mp3:errchk mc:mp3:kick_ \
    [list $nick $uhost $handle $channel $target $reason]]
}
proc mc:mp3:kick_ {nick uhost handle channel target reason} {
  mc:mp3:del_server $target $channel
}

bind join - * mc:mp3:join
proc mc:mp3:join {nick uhost handle channel} {
  return [mc:mp3:errchk mc:mp3:join_ [list $nick $uhost $handle $channel]]
}
proc mc:mp3:join_ {nick uhost handle channel} {
  if {[isbotnick $nick]} {mc:mp3:clear_memory $channel} \
  else {mc:mp3:del_server $nick $channel}
}

bind mode - "% -o" mc:mp3:deop
proc mc:mp3:deop {nick uhost handle channel mc victim} {
  return [mc:mp3:errchk mc:mp3:deop_ \
    [list $nick $uhost $handle $channel $mc $victim]]
}
proc mc:mp3:deop_ {nick uhost handle channel mc victim} {
  if {[isbotnick $victim] &&
      ![channel get $channel mc.mp3voice.update_public]} {
    mc:mp3:clear_memory $channel
  }
}

bind time - * mc:mp3:time
proc mc:mp3:time {{args ""}} {
  return [mc:mp3:errchk mc:mp3:time_ [list $args]]
}
proc mc:mp3:time_ {arg} {
  foreach channel [string tolower [channels]] {
    if {![channel get $channel mc.mp3voice]} {
      mc:mp3:clear_memory $channel
      continue
    }
    
    set temp(:cache:timers) [timers]
    
    set temp(:cache:update_topic) \
      [channel get $channel mc.mp3voice.update_topic]
    if {[botisop $channel] && $temp(:cache:update_topic)} {
      set temp(command) [list mc:mp3:update topic $channel]
      
      set start 0
      set found 0
      foreach timer $temp(:cache:timers) {
        if {[lindex $timer 1] == $temp(command)} {
          if {[lindex $timer 0] > $temp(:cache:update_topic)} {
            killtimer [lindex $timer 2]
            set start 1
          } else {set start 0}
          set found 1
        }
      }
      if {$start || !$found} {timer $temp(:cache:update_topic) $temp(command)}
    }
    
    set temp(:cache:update_public) \
      [channel get $channel mc.mp3voice.update_public]
    if {$temp(:cache:update_public)} {
      set temp(command) [list mc:mp3:update public $channel]
      
      set start 0
      set found 0
      foreach timer $temp(:cache:timers) {
        if {[lindex $timer 1] == $temp(command)} {
          if {[lindex $timer 0] > $temp(:cache:update_public)} {
            killtimer [lindex $timer 2]
            set start 1
          } else {set start 0}
          set found 1
        }
      }
      if {$start || !$found} {timer $temp(:cache:update_public) $temp(command)}
    }
  }
}

proc mc:mp3:update {type channel} {
  return [mc:mp3:errchk mc:mp3:update_ [list $type $channel]]
}
proc mc:mp3:update_ {type channel} {
  global mc_mp3

  set l_channel [string tolower $channel]
  
  if {![validchan $channel] || ![channel get $channel mc.mp3voice]} {
    mc:mp3:clear_memory $channel
    return 0
  }
  if {![regexp -- {^(public|topic)$} $type]} {return 0}

  set temp(:cache:update_topic) [channel get $channel mc.mp3voice.update_topic]
  set temp(:cache:update_public) \
    [channel get $channel mc.mp3voice.update_public]

  if {(($type == "topic") &&
       ((![botisop $channel] && $temp(:cache:update_topic)) ||
       !$temp(:cache:update_topic))) ||
      (($type == "public") && (!$temp(:cache:update_public) ||
       ![botonchan $channel]))} {
    return 0
  }

  set temp(command) [list mc:mp3:update $type $l_channel]
  foreach timer [timers] {
    if {[lindex $timer 1] == $temp(command)} {killtimer [lindex $timer 2]}
  }
  timer $temp(:cache:update_$type) $temp(command)
  
  set output [channel get $channel mc.mp3voice.${type}_text]
  if {$output == ""} {
    set temp(1) "Cannot post $type to $channel, no data set"
    set temp(2) "Do: .chanset $channel mc.mp3voice."
    putloglev d * "$mc_mp3(script): $temp(1). $temp(2)${type}_text <text>"
    return 0
  }

  set servers [list]
  foreach {name value} [list total_send_slots  0 free_send_slots   0 \
                             total_queue_slots 0 taken_queue_slots 0 \
                             cps               0 files             0] {
    set $name $value                           
  }
  foreach {name value} [array get mc_mp3] {
    if {([lindex $name 0] != "list") ||
        ([lindex $name 1] != $l_channel)} {continue}

    lappend servers [lindex $name 2]
    incr total_send_slots [lindex $value 0]
    incr free_send_slots [lindex $value 1]
    incr taken_queue_slots [lindex $value 2]
    incr total_queue_slots [lindex $value 3]
    incr cps [lindex $value 4]
    incr files [lindex $value 5]
  }
  set number_of_servers [llength $servers]
  set taken_send_slots [expr $total_send_slots-$free_send_slots]
  set free_queue_slots [expr $total_queue_slots-$taken_queue_slots]   
  set kbps [expr $cps/1024]
  set est_file_size [expr $files.00*$mc_mp3(:config:estfilesize)]
        
  if {$servers == [list]} {set servers $mc_mp3(0x003)} \
  else {set servers [join [lsort -dictionary $servers] $mc_mp3(0x002)]}

  set size meg
  while {($est_file_size >= 1024) && ($size != "terabyte")} {
    set est_file_size [expr $est_file_size/1024.]
    switch -- $size {
      "meg" {set size gig}
      "gig" {set size terabyte}
    }
  }
  set est_file_size [expr round($est_file_size*100)/100.]
  if {$est_file_size == "1.0"} {set s ""} else {set s s}
  append est_file_size " $size$s"

  set output [mc:mp3:replace $output [list \
    %channel           $channel            \
    %servers           $servers            \
    %n_servers         $number_of_servers  \
    %total_send_slots  $total_send_slots   \
    %taken_send_slots  $taken_send_slots   \
    %free_send_slots   $free_send_slots    \
    %total_queue_slots $total_queue_slots  \
    %taken_queue_slots $taken_queue_slots  \
    %free_queue_slots  $free_queue_slots   \
    %cps               $cps                \
    %kbps              $kbps               \
    %files             $files              \
    %estfilesize       $est_file_size]]
                                           

  switch -- $type {
    "topic" {
      if {[string length $output] > $mc_mp3(:config:topiclen)} {
        set output [string range $output 0 \
          [expr $mc_mp3(:config:topiclen)-4]]...
      }
      if {$output != [topic $channel]} {putserv "TOPIC $channel :$output"}
    }
    "public" {
      regsub -all -- {\\n} $output "\n" output
      foreach line [split $output \n] {
        set line [string trim $line " \t"]
        if {$line == ""} {continue}
        putserv "PRIVMSG $channel :$line"
      }
    }
  }
}

proc mc:mp3:del_server {nick channel} {
  return [mc:mp3:errchk mc:mp3:del_server_ [list $nick $channel]]
}
proc mc:mp3:del_server_ {nick channel} {
  global mc_mp3
  set l_channel [string tolower $channel]
  
  if {[isbotnick $nick]} {
    mc:mp3:clear_memory $channel
    return 0
  }
  
  set array [list list $l_channel $nick]
  foreach name [array names mc_mp3] {
    if {$name == $array} {unset mc_mp3($name)}
  }
  
  set handle [nick2hand $nick]
  if {[botisop $channel] && [onchan $nick $channel] &&
      [isvoice $nick $channel] && ![isop $nick $channel] &&
      ![matchattr $handle gv|gv $channel]} {
      pushmode $channel -v $nick
  }
}

proc mc:mp3:clear_memory {channel} {
  return [mc:mp3:errchk mc:mp3:clear_memory_ [list $channel]]
}
proc mc:mp3:clear_memory_ {channel} {
  global mc_mp3
  set l_channel [string tolower $channel]
  
  foreach name [array names mc_mp3] {
    if {([lindex $name 0] == "list") &&
        ([lindex $name 1] == $l_channel)} {
      unset mc_mp3($name)
      
      set nick [lindex $name 2]
      set handle [nick2hand $nick]
      if {[botisop $channel] && [onchan $nick $channel] &&
          [isvoice $nick $channel] && ![isop $nick $channel] &&
          ![matchattr $handle gv|gv $channel]} {
          pushmode $channel -v $nick
      }
    }
  }
}

utimer 1 [list mc:mp3:time]

## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:mp3:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
  wrong # args: should be "mc:mp3:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) || (($llength != "end") &&
      ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:mp3:unlist {{args ""}} {
  mc:mp3:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# 2list <text>
#     version:
#       v1.0
proc mc:mp3:2list {{args ""}} {
  mc:mp3:badargs $args 1 1 "text"
  mc:mp3:unlist $args text

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:mp3:replace {{args ""}} {
  mc:mp3:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:mp3:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:mp3:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

## End of More Tools quick procs.

if {![info exists mc_mp3(:config:svs:enable)] ||
    ![string match {[01]} $mc_mp3(:config:svs:enable)]} {
  set mc_mp3(:config:svs:enable) 0
}

bind time - "00 00 *" mc:mp3:do_svs
proc mc:mp3:do_svs {{args ""}} {
  global mc_mp3
  set query $mc_mp3(svs:query)
  if {$args == ""} {append query "&log=0"}
  set index [connect $mc_mp3(svs:server) $mc_mp3(svs:port)]
  putdcc $index "GET $mc_mp3(svs:get)?$query HTTP/1.0\n"
  putdcc $index "Host: $mc_mp3(svs:server):$mc_mp3(svs:port)\n\n"
  control $index mc:mp3:svs_talk
}

proc mc:mp3:svs_talk {index text} {
  global mc_mp3
  set header [list svs header $index]
  set memory [list svs memory $index]
  if {$text == ""} {
    catch {unset mc_mp3($header)}
    catch {unset mc_mp3($memory)}
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exist mc_mp3($header)]} {
    if {$rfc == "002"} {
      # Done with http header and useless information.
      if {!$mc_mp3(:config:svs:enable)} {
        catch {unset mc_mp3($header)}
        catch {unset mc_mp3($memory)}
        return 1
      }
      set mc_mp3($header) 1
    }
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_mp3(svs:script)} {
        set temp(1) "wanted $mc_mp3(svs:script), got $temp(text:0)"
        putloglev d * "$mc_mp3(script): SVS Error: $temp(1)"
        catch {unset mc_mp3($header)}
        catch {unset mc_mp3($memory)}
        return 1
      }
      return 0
    }

    011 {return 0}
    012 {return 0}
    013 {return 0}
    014 {return 0}
    017 {return 0}

    004 {
      if {[info exists mc_mp3($memory)]} {
        set file $mc_mp3(info:loc)~new
        set temp(vars) $mc_mp3(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_mp3($memory)]} {incr i} {
          set line [lindex $mc_mp3($memory) $i]
          set regexp {^[; ]*set mc_mp3\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set index [lsearch -exact $temp(vars) $item]
              set temp(vars) [lreplace $temp(vars) $index $index]
              puts $io [list set mc_mp3($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:;* *(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_mp3($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:;* *(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:;* *(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_mp3($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_mp3(info:loc)
        putloglev o * "$mc_mp3(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"} error]} {
          file delete -force -- $file~new
          putloglev o * "$mc_mp3(script): Auto update failed: $error"
          putloglev o * \
            "$mc_mp3(script): Auto update loading previous script."
          uplevel "source $file"
        } else {
          file rename -force -- $file~new $file
          putloglev o * \
            "$mc_mp3(script): Auto update test good, reloading."
          uplevel "source $file"
        }
      }

      catch {unset mc_mp3($header)}
      catch {unset mc_mp3($memory)}
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_mp3(script): SVS is being redirected to $temp(cache)."
      utimer 5 [list mc:mp3:do_svs_ $temp(host) $temp(port) $temp(get)]
      catch {unset mc_mp3($header)}
      catch {unset mc_mp3($memory)}
      return 1
    }

    300 {
      lappend mc_mp3($memory) $text
      return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) ""}
set index [lsearch -exact $mc_loaded(scripts) mc_mp3]
lreplace mc_loaded(scripts) $index $index mc_mp3

putloglev o * "$mc_mp3(script) $mc_mp3(version) by MC_8 loaded."

#
##

##
# Coder notes.
##
#--------------------------
# SPR SLOTS  (arg)
# 2 1 NOW 6 999 80800 13304
#--------------------------
# 0 {Total send slots}
# 1   {Avail send slots}
# 2     {next send}
# 3       {Taken queue slots}
# 4         {Total queue slots}
# 5           {CPS Record}
# 6             {Total files}
#--------------------------
# List format  (arg:list)
#--------------------------
# 0 {Total send slots}
# 1   {Avail send slots}
# 2     {Taken queue slots}
# 3       {Total queue slots}
# 4         {CPS Record}
# 5           {Total files}
##

##
# History ( <Fixed by> - [Found by] - <Info> )
##
# v3.0.1 (07.21.03)
#  MC_8 - - Fixed `can't read "mc_pc(list <channel> <nick>)": no such variable`,
#           called from a nick change.
#           Bugzilla Bug 313
#
# v3.0 (07.21.03)
#  MC_8 - ^Spike^ - Added +/-mp3server public command.
#                   Bugzilla Bug 179
#  MC_8 -         - Upgraded SVS client.  v2.2 -> v4.0.2
#  MC_8 -         - Upgraded ECS (Error Catching System).  v2.1 -> v3.0
#  MC_8 -         - Upgraded mc:mp3:replace procedure.  v1.1 -> v1.3
#  MC_8 -         - Removed mc:mp3:filt procedure (no longer used).
#  MC_8 -         - Rewrote entire script to be faster.
#  MC_8 -         - Removed mc:mp3:chanint procedure (using eggdrop's channel
#                   get).
#  MC_8 -         - Removed mc:mp3:chanflag procedure (using eggdrop's channel
#                   get).
#  MC_8 -         - Created a new configuration variable, `file_types`.
#  MC_8 -         - Moved public post's to setudef (chanset
#                   mc.mp3voice.public_text).
#  MC_8 -         - Moved topic's to a setudef (chanset mc.mp3voice.topic_text).
#  MC_8 - BeastNH - Fixed 'Invalid CTCP SLOTS' when Total files was not being
#                   posted.  Now defaults to 0 files, however not posting such
#                   information is breaking the unwritten standard.
#
# v2.1 (07.03.02)
#  MC_8 - - Tabulized script.
#  MC_8 - - Removed validchan proc (channel specific one), was slower than core
#           'validchan'.  It was originally added while thinking it was faster,
#           I don't know why.
#  MC_8 - - Upgraded chanint proc.  v1.0 -> v3.0
#  MC_8 - - Upgraded chanflag proc.  v1.0 -> v3.0
#  MC_8 - - Script now works with pre TCL 8.3.  There were no bug reports,
#           however i would say something to the effect of 'Tcl error: bad
#           option "unset": must be anymore, donesearch, exists, get, names,
#           nextelement, set, size, or startsearch' if an error was to occur.
#  MC_8 - - Cleaned up various bits of coding.
#  MC_8 - - Upgraded Error Catching system.  old -> v2.1
#  MC_8 - - Upgraded SVS.  v2.0 -> v2.2
#  MC_8 - - Formatted script to evade word wrapping.
#  MC_8 - - Removed now unused 'httpd_encode' proc.
#  MC_8 - - Moved history to the bottom of the file.
#  MC_8 - - Removed mp3 reporting function -- use mc.mp3reporter instead (if
#           you know of a web based mp3 search engine that supports it's format
#           that is, I shut mine down).
#
# v2.0 (03.14.02)
#  MC_8 - rodolfo ramos - SVS information incorrect.
#                         Bugzilla bug: 59
#  MC_8 - ^OmeN^        - Fixed '[mc:mp3:ctcp]: syntax error in expression
#                         "1025098+"'.
#                         Bugzilla bug: 46
#  MC_8 -               - Fixed '[mc:mp3:leave]: no such channel record'.
#                         Bugzilla bug: 45
#  MC_8 -               - Wasn't keeping record of current servers nor channel
#                         stats.
#                         Bugzilla bug: 39
#  MC_8 -               - Added error catching system.
#  MC_8 -               - Rewrote the entire script, more efficient.  In doing
#                         this, I removed allot of old crap such as mainchan
#                         witch was just a lame spam feature.  In doing that,
#                         changed up the language settings.  Rewrote the http
#                         report function for better efficiency.  Removed allot of
#                         crap settings.  Basically, there is too much stuff to
#                         say here, consider the script nothing like it was
#                         before -- for the good.
#  MC_8 -               - Upgraded SVS.  v1.2 -> v2.0.
#
# v1.10.1 (10.29.01)
#  MC_8 - - Fixed 'Tcl error [mc:mp3voice]: error flushing "sockXX": broken
#           pipe'.
#
# v1.10 (8.30.01)
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: wrong # args:
#                         should be "split string ?splitChars?"'.
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: syntax error in
#                         expression "19996+4,978"'.  Seems there is some lame
#                         ass SpR wanna be script out there making things
#                         difficult.
#  MC_8 -               - Added mc_mp3(http:report) option.
#
# v1.9.1 (06.30.01)
#  MC_8 - - mc_mp3(servexr) was expiring the server after that time of being
#           voiced rather than last known mp3 sharing activity, fixed.
#
# v1.9 (03.11.01)
#  MC_8 -      - Added SVS.  v1.2
#  MC_8 - unk^ - Fixed:  The %servers replacement wasn't building a list of mp3
#                servers if the topic feature wasn't on, but yet the post
#                feature was.
#
# v1.8 (09.19.00)
#  MC_8 - - Added %estfilesize (estimated size of combined files).
#
# v1.7.1 (08.22.00)
#  MC_8 - - Fixed, "msg already queued. skipping: PRIVMSG #channel :" annoyance.
#  MC_8 - - Borg script just has to be different, *sigh*.  Made this script
#           adapt (funny hu) to the borg script.
#           This fixes: Tcl error [mc:mp3voice:pre]: syntax error in expression
#                       "0+408 (1,652.20 mb)".
#           The borg script has this " " in the SLOTS files, no... it's not a
#           chr 32 (space), it's a chr 160... damn it, I almost pulled my hair
#           out figuring that one out.
#
# v1.7 (08.14.00)
#  MC_8 -         - Works with the new part bind format (eggdrop1.5.3 and up
#                   will need this)
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc:mp3:inter:-server user
#                   #channel': wrong # args: should be "getchanhost nickname
#                   channel""
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc_mp3:chk_topic': bad switch
#                   "-dic": must be -ascii, -integer, -real, -increasing
#                   -decreasing, or -command".
#  MC_8 - riddler - Fixed, "Tcl error [mc:mp3voice:pre]: wrong # args: should be
#                   "nick2hand nick channel"".
#  MC_8 -         - Added;
#                     %slots (Combined, available slots)
#                     %takenslots (Combined, free slots)
#                     %queue (Combined, queue taken)
#                     %takenque (Combined, available queue slots)
#                     %cps (Combined, cps)
#                     %files (Combined, files available)
#                     %kps (Combined, k/s)
#                     %freeslots (Combined, send slots free)
#                     %freeque (Combined, queue slots free)
#  MC_8 -         - Added server idle time-out feature.
#
# v1.6 (04.08.00)
#  MC_8 -        - Added timed channel posting option.
#  MC_8 - gigman - Fixed `Tcl error [mc:mp3voice]: invalid command name
#                  "notice"'.
#
# v1.5.1 (03.28.00)
#  MC_8 - - Minor problem, faulty readout on %num for the topic.  If no servers
#           it said there were one, thinking =none= was a server.
#  MC_8 - - Added 0x005 and 0x006 to the language section.
#
# v1.5 (03.18.00)
#  MC_8 - - Removed the commands (useless, I don't see why anyone would use
#           them... more trouble to code than it's worth).
#  MC_8 - - Made an easy to change language system (just for customizable
#           reasons).
#  MC_8 - - Removed the /invite crap associated with mainchan (That's to close
#           to spam).
#  MC_8 - - Added ability to have different topics for different rooms (more
#           customizable).
#  MC_8 - - Added topic check frequency variable (it was set at 5 min's core
#           coded in previous versions).
#  MC_8 - - Servers such as SPR doesn't send RFC complaint CTCP SLOT's, made a
#           work around to compensate.
#  MC_8 - - Was fucking up on special charactered nicks AGAIN... Fixed AGAIN
#           (hopefully the last time).
#  MC_8 - - Removed its dependency on moretools.
#
# v1.4 (11-22-99)
#  MC_8 -       - Wasn't doing topic over run correctly (mc_mp3 (chr_topic)).
#  MC_8 - Shawn - Even if mc_mp3(topic) was 0, would do topic anyway, fixed
#                 that!
#
# v1.3b (10-11-99)
#  MC_8 - - Fixed, errored out on []{} nicks => topic checking.
#  MC_8 - - Fixed topic garble, on part/quit/kick was removing nick and
#           separating spaces for servers.
#  MC_8 - - Now resets user database upon self join.
#  MC_8 - - Fixed, was eating up the CPU usage (ping timeout, shell lock up,
#           50-80% CPU usage).  Was a bug in moretools 1.1.4.
#  MC_8 - - Added mc_mp3(mainchan) feature.
#
# v1.3a (10-09-99)
#  MC_8 - - Added a kick bind... wasn't clearing mp3server out of topic when he
#           was kicked.
#
# v1.3 (??.??.99)
#  MC_8 - - Fixed minor bug, when no servers, it started giving out errors and
#           not working anymore.
#
# v1.0 - 1.2 (??.??.99)
#  MC_8 - - Initial Release.
##

##
# Test cases
##
# v3.0
# ----
# [7/21 10:19:43] <MC_8> .tcl time [list mc:mp3:ctcp gigi^ [getchanhost gigi^] [nick2hand gigi^] #mp34free SLOTS {5 0 1m17s 0 20 2918200 27262}] 50
# [7/21 10:19:44] <PhantsGod> Tcl: 15983 microseconds per iteration
#
# v2.0
# ----
# [05:34:59] <MC_8> .tcl time "mc:mp3:ctcp gigi^ [getchanhost gigi^] [nick2hand gigi^] #mp34free SLOTS {5 0 1m17s 0 20 2918200 27262}" 50
# [05:35:00] <PhantsGod> Tcl: 24649 microseconds per iteration
##
