##
# MP3 Voice v2.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script will auto voice a user for sharing an mp3.  The script detects mp3
# sharing via ctcp mp3 and ctcp slots (spr type serving).  Also has topic and channe
# posting features.
#
# If you have stumbled upon this script while looking for a tcl script for eggdrop
# that will voice users if there running a server (something like an fserve or ftp
# post), this is not the script for you.  This script is only for spr type serving.
# But, your not out of luck.  You can use my '(de)Voice Command'
# (mc.(de)voice-cmd.tcl) script for that purpose.  You can find that script on my SVS
# Website advertisment above, in the header of this script.
##

##
# HISTORY -- Moved to the bottom of the file.
##


##
# COMMANDS (dcc)
##
# chanset <#channel> <-/+>mc.mp3voice
#   Setting this enables (+) or disables (-) the script for the particular channel.
#
# chanset <#channel> mc.mp3voice.update_topic <number>
#   How often, in min's, do you want to update the topic of the specific channel?
#   Setting this to 0 disables this function.
#
# chanset <#channel> mc.mp3voice.update_public <number>
#   How often, in min's, do you want to update the specific channel?  Updating the
#   channel consists of a public PRIVMSG.  Setting this to 0 disables this function.
##

##
# Settings
##

# How long, in min's, of not recieving signs of a user serving do you want to wait
# before removing the user from the active servers list?  Keep in mind, serving is
# justified by channel CTCP SLOTS and CTCP MP3's.  Set this to 0 to never remove the
# user from the active servers list.
set mc_mp3(expire_server) 30

# Set this to the topic message you want to set.  In relation to the update_topic dc
# chanset.  Each different channel can have it's own personal topic set here, or you
# can just use 'default''s topic.  Set this veriable in this fasion:
#   set mc_mp3(:topic:<'#'channel|'default'>) "<The topic for the channel.>"
# Replacment veriables:
#  %channel           - The channels name.
#  %servers           - The list of active servers for the channel.
#  %n_servers         - Number of active servers in the channel.
#  %total_send_slots  - Overall available send slots for the channel.
#  %taken_send_slots  - Overall number of send slots that are currently in use.
#  %free_send_slots   - Overall number of send slots free for use.
#  %total_queue_slots - Overall avilable que slots for the channel.
#  %taken_queue_slots - Overall number of que slots that are currently in use.
#  %free_queue_slots  - Overall number of que slots free for use.
#  %cps               - Overall highest recorded characters per second.
#  %kps               - Overall highest recorded kilobytes per second.
#  %files             - Overall number of files currently offered to the channel.
#  %estfilesize       - Estamated size of overall files currently offered to the
#                       channel.
set mc_mp3(:topic:#mp34free) "8,2%channel4(8%n_servers 11servers4/8%files 11files4~8%estfilesize4)11 Current Servers: 8%servers11."
set mc_mp3(:topic:default) "%channel is rocking with %n_servers active server(s): %servers"

# How many characters will the server allow in the topic?  If you set this too long,
# and you've chosen to have this script auto update the topic, the topic will be
# updated once every minute regardless if it needs it or not -- so please either
# under set it or set it correctly.  If you don't know what this should be set to, d
# this;
#   1) Join a temp channel on the irc server of your choise.
#   2) Set the topic to a really long topic.
#   3) Once the topic is set, you should see that it got cut off.  If it did not get
#      cut off, then set the topic even longer and longer untill it finally does get
#      cut off by the server.
#      Q: What's 'cut off' mean?
#      A: You set the topic to "Hello everyone!", but after you set it, it only show
#         "Hello ev".  It got cut off by the server.
#   4) Count the number of characters in the cut off topic, That's the topic limit
#      for that server.
# Here are some I already know, as of 8:08am 02-07-02;
#   DALnet   = 307
#   EFnet    = 120
#   IRCnet   = 160
#   Undernet = 160
set mc_mp3(topiclen) 160

# Set this to the public message you want to post.  In relation to the update_public
# dcc chanset.  Each different channel can have it's own personal post set here, or
# you can just use 'default''s topic.  Set this veriable in this fasion:
#   set mc_mp3(:public:<'#'channel|'default'>) {
#    <The public post here, line 1>
#    <The public post here, line 2>
#   }
# As you can see, it can be multi lined.  Seperate each new line with a new line.
# Replacment veriables:
#  %channel           - The channels name.
#  %servers           - The list of active servers for the channel.
#  %n_servers         - Number of active servers in the channel.
#  %total_send_slots  - Overall available send slots for the channel.
#  %taken_send_slots  - Overall number of send slots that are currently in use.
#  %free_send_slots   - Overall number of send slots free for use.
#  %total_queue_slots - Overall avilable que slots for the channel.
#  %taken_queue_slots - Overall number of que slots that are currently in use.
#  %free_queue_slots  - Overall number of que slots free for use.
#  %cps               - Overall highest recorded characters per second.
#  %kps               - Overall highest recorded kilobytes per second.
#  %files             - Overall number of files currently offered to the channel.
#  %estfilesize       - Estamated size of overall files currently offered to the
#                       channel.
set mc_mp3(:public:#mp34free) {
12,2 1011 Welcome to 8%channel11, we have8 %n_servers 11detected servers online to serve you:8 %servers11. 1012 
12,2 1011 Combined channel status: 4(8%files11files4~8%estfilesize4) (8%free_send_slots11 Free Send Slots4)11-4(8%free_queue_slots11 Free Que Slots4)11->4[(8%taken_send_slots4/8%total_send_slots4)11 Slots Taken 4(8%taken_queue_slots4/8%total_queue_slots4)11 Ques Taken4] [11Highest Cps Record: 8%kpsk/s4] 111012 
}
set mc_mp3(:public:default) {
12,2 1011 Welcome to 8%channel11, we have8 %n_servers 11detected servers online to serve you:8 %servers11. 1012 
}

# The %estfilesize replacment veriable used in public and topic updates is calculate
# by the number of files offered to the channel times the number you set below.
# What's the average size, in megabytes, of the files being offered in your channels?
set mc_mp3(estfilesize) 8


## MC SVS (Script Version Service) v2.2 ##
# Do you want the bot to connection to MC_8's SVS server to see if there's a
# newer version of this script available?  It will only tell you, it's up to you
# to get the newest version and re-configure it as needed.
#   0 = No, do not enable SVS.
#   1 = Yes, but only inform me of non beta versions.
#   2 = Yes, inform me of all new versions (beta and stable).
set mc_mp3(svs:mode) 2

# Upon finding a newer version, whom do you want to notify?  The notification is
# sent via 'note'.  Separate each user with a space.  For those whom know TCL;
# do not put this in list format, keep it in string format.
set mc_mp3(svs:notify) "MC_8"

##

##
# Language
##

# Trigged upon a user detected serving and not voiced nor opped and the user doesn't
# have the 'q' flag. 1st word either NOTICE or PRIVMSG.
#  Using veriables: %chan
set mc_mp3(0x001) "NOTICE 12 You have been voiced in %chan for sharing your mp3's, thank you."

# What do you want to split the %servers with?
# Ie.  Server1, Server2, Server3
#      The ", " is the split.
set mc_mp3(0x002) "11, 8"

# If there are not servers, %servers return this.
set mc_mp3(0x003) "=none="

##

##
# Edit no further, tcl coding below.
##

#Script:mc_mp3

set mc_mp3(script)      "MP3 Voice"
set mc_mp3(version)     "v2.1"
set mc_mp3(svs:script)  "mp3voice"
set mc_mp3(svs:version) "002001000000"
set mc_mp3(svs:server)  "mc.purehype.net"
set mc_mp3(svs:port)    "81"
set mc_mp3(svs:get)     "/"
set mc_mp3(svs:query)   "svs=$mc_mp3(svs:script)&version=$mc_mp3(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_mp3(script) $mc_mp3(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef flag mc.mp3voice
setudef int mc.mp3voice.update_topic
setudef int mc.mp3voice.update_public

# Error system, v2.1
proc mc:mp3:error {bindproc error {arg ""}} {
	global mc_mp3 version lastbind
	putlog "Error in script $mc_mp3(script) $mc_mp3(version)."
	if {[info exists lastbind]} {set temp(x) $lastbind} \
	else {set temp(x) -NULL-}
	putlog "       Last bind: $temp(x)"
	putlog "       Procedure: $bindproc"
	putlog "            Args: $arg"
	if {[info exists version]} {set temp(x) $version} \
	else {set temp(x) -NULL-}
	putlog " Eggdrop version: $temp(x)"
	putlog "     TCL version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please tell MC_8 about this BUG!  Visit        "
	putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
	putlog "*** Please include the next line in the bug report."
	error $error
}

proc mc:mp3:errchk {command arg} {
	if {[catch {eval $command $arg} return]} {
		mc:mp3:error $command $return $arg
		return 0
	}
	return $return
}
# ^

foreach {name value} [array get mc_mp3 :topic:*] {
	if {![regexp -- {[A-Z]} $name]} {continue}
	# Do not use 'array unset', backwards compatable with TCL 8.0.
	unset mc_mp3($name)
	set mc_mp3([string tolower $name]) $value
}

bind pub - \001MP2 mc:mp3:pub:ctcp:mp3
proc mc:mp3:pub:ctcp:mp3 {nick uhost hand chan arg} {
	mc:mp3:ctcp $nick $uhost $hand $chan MP2 $arg
}

bind pub - \001MP3 mc:mp3:pub:ctcp:mp3
proc mc:mp3:pub:ctcp:mp3 {nick uhost hand chan arg} {
	mc:mp3:ctcp $nick $uhost $hand $chan MP3 $arg
}

bind pub - \001SLOTS mc:mp3:pub:ctcp:slots
proc mc:mp3:pub:ctcp:slots {nick uhost hand chan arg} {
	mc:mp3:ctcp $nick $uhost $hand $chan SLOTS $arg
}

bind ctcp - MP2 mc:mp3:ctcp
bind ctcp - MP3 mc:mp3:ctcp
bind ctcp - SLOTS mc:mp3:ctcp

proc mc:mp3:ctcp {nick uhost hand chan key arg} {
	return [mc:mp3:errchk mc:mp3:ctcp_ [list $nick $uhost $hand $chan $key $arg]]
}
proc mc:mp3:ctcp_ {nick uhost hand chan key arg} {
	global mc_mp3
	if {![validchan $chan] || ![mc:mp3:chanflag $chan mc.mp3voice]} {
		return 0
	}

	set lchan [string tolower $chan]
	set lnick [string tolower $nick]
	set temp(:setting:botisop) [botisop $chan]
	set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]
	set temp(:setting:update_public) [mc:mp3:chanint $chan mc.mp3voice.update_public]

	switch -- [string toupper $key] {
		SLOTS {
			if {($temp(:setting:botisop) && $temp(:setting:update_topic)) ||
			    $temp(:setting:update_public)} {

				set temp(arg) [split $arg]
				set temp(arg:new) [lrange $temp(arg) 0 5]
				set temp(1) [split [lindex $temp(arg) 6] [format %c 160]]
				lappend temp(arg:new) [mc:mp3:replace [lindex $temp(1) 0] [list , ""]]
				set temp(arg) $temp(arg:new)
				unset temp(arg:new)

				set temp(arg:0) [lindex $temp(arg) 0] ;# Total send slots
				set temp(arg:1) [lindex $temp(arg) 1] ;# Avail send slots
				set temp(arg:3) [lindex $temp(arg) 3] ;# Taken queue slots
				set temp(arg:4) [lindex $temp(arg) 4] ;# Total queue slots
				set temp(arg:5) [lindex $temp(arg) 5] ;# CPS Record
				set temp(arg:6) [lindex $temp(arg) 6] ;# Total files

				set temp(arg:list) [list $temp(arg:0) $temp(arg:1) $temp(arg:3) \
					$temp(arg:4) $temp(arg:5) $temp(arg:6)]
				if {($temp(arg:6) == "") || ($temp(arg:0) < $temp(arg:1)) ||
				    ($temp(arg:3) > $temp(arg:4)) ||
				    [regexp -- {[^0-9 ]} [join $temp(arg:list)]]} {
					putlog "$mc_mp3(script): Invalid CTCP SLOTS post from $nick on $chan: $arg"
					return 0
				}
				set array_chan [list list $lchan]
				set array_nick [list list $lchan $lnick]
				if {![info exists mc_mp3($array_chan)]} {
					set mc_mp3($array_chan) $temp(arg:list)
				} elseif {[info exists mc_mp3($array_nick)]} {
					if {$mc_mp3($array_nick) != $temp(arg:list)} {

						set temp(array_chan:0) [lindex $mc_mp3($array_chan) 0]
						set temp(array_chan:1) [lindex $mc_mp3($array_chan) 1]
						set temp(array_chan:2) [lindex $mc_mp3($array_chan) 2]
						set temp(array_chan:3) [lindex $mc_mp3($array_chan) 3]
						set temp(array_chan:4) [lindex $mc_mp3($array_chan) 4]
						set temp(array_chan:5) [lindex $mc_mp3($array_chan) 5]

						set temp(array_nick:0) [lindex $mc_mp3($array_nick) 0]
						set temp(array_nick:1) [lindex $mc_mp3($array_nick) 1]
						set temp(array_nick:2) [lindex $mc_mp3($array_nick) 2]
						set temp(array_nick:3) [lindex $mc_mp3($array_nick) 3]
						set temp(array_nick:4) [lindex $mc_mp3($array_nick) 4]
						set temp(array_nick:5) [lindex $mc_mp3($array_nick) 5]

						# A new slots post, re-evaluate the sum of the channel -- current number
						# minus that user's last post number plus the channel's sum number.
						# So, example, if user had 1 file before, now has 2 -- and the channel
						# sum before was 5.  The new chanel sum would be (2-1)+5=6.
						set mc_mp3($array_chan) [list \
							[expr ($temp(arg:0)-$temp(array_nick:0))+$temp(array_chan:0)]\
							[expr ($temp(arg:1)-$temp(array_nick:1))+$temp(array_chan:1)]\
							[expr ($temp(arg:3)-$temp(array_nick:2))+$temp(array_chan:2)]\
							[expr ($temp(arg:4)-$temp(array_nick:3))+$temp(array_chan:3)]\
							[expr ($temp(arg:5)-$temp(array_nick:4))+$temp(array_chan:4)]\
							[expr ($temp(arg:6)-$temp(array_nick:5))+$temp(array_chan:5)]]
					}
				} else {
					set mc_mp3($array_chan) [list \
						[expr [lindex $mc_mp3($array_chan) 0]+$temp(arg:0)]\
						[expr [lindex $mc_mp3($array_chan) 1]+$temp(arg:1)]\
						[expr [lindex $mc_mp3($array_chan) 2]+$temp(arg:3)]\
						[expr [lindex $mc_mp3($array_chan) 3]+$temp(arg:4)]\
						[expr [lindex $mc_mp3($array_chan) 4]+$temp(arg:5)]\
						[expr [lindex $mc_mp3($array_chan) 5]+$temp(arg:6)]]
				}
				set mc_mp3($array_nick) $temp(arg:list)
			}
		}
		MP2 {}
		MP3 {}
	}
	if {$temp(:setting:botisop)} {
		if {![isvoice $nick $chan] && ![isop $nick $chan]} {
			if {[matchattr $hand q|q $chan]} {
				set temp(1) "Cannot voice $nick (hand: $hand) for serving in $chan"
				putlog "$mc_mp3(script): $temp(1), user has the 'q' flag."
			} else {
				pushmode $chan +v $nick
				set temp(1) [split $mc_mp3(0x001)]
				set method [string toupper [lindex $temp(1) 0]]
				set msg [mc:mp3:replace [join [lrange $temp(1) 1 end]] [list %chan $chan]]
				if {[regexp -- {^(NOTICE|PRIVMSG)$} $method]} {
					puthelp "$method $nick :$msg"
				}
			}
		}
		if {$mc_mp3(expire_server)} {
			set temp(:setting:timers) [timers]
			set temp(1) [mc:mp3:filt [list [list mc:mp3:del_server $nick $chan]]]
			set temp(2) [lsearch -glob $temp(:setting:timers) "* $temp(1) timer*"]
			if {$temp(2) != "-1"} {
				killtimer [lindex [lindex $temp(:setting:timers) $temp(2)] 2]
			}
			timer $mc_mp3(expire_server) [list mc:mp3:del_server $nick $chan]
		}
	}
	if {($temp(:setting:update_topic) && $temp(:setting:botisop)) ||
	    $temp(:setting:update_public)} {
		set array_serv [list servers $lchan]
		if {![info exists mc_mp3($array_serv)]} {
			set mc_mp3($array_serv) [list $nick]
		} elseif {[lsearch -exact $mc_mp3($array_serv) $nick] == "-1"} {
			lappend mc_mp3($array_serv) $nick
		}
	}
	return 0
}

bind part - * mc:mp3:leave
bind sign - * mc:mp3:leave
proc mc:mp3:leave {nick uhost hand chan arg} {
	mc:mp3:del_server $nick $chan 1
}

bind nick - * mc:mp3:nick
proc mc:mp3:nick {nick uhost hand chan newnick} {
	return [mc:mp3:errchk mc:mp3:nick_ [list $nick $uhost $hand $chan $newnick]]
}
proc mc:mp3:nick_ {nick uhost hand chan newnick} {
	global mc_mp3

	set lchan [string tolower $chan]
	set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]

	if {![mc:mp3:chanflag $chan mc.mp3voice] ||
	    (((![botisop $chan] && $temp(:setting:update_topic)) ||
	     !$temp(:setting:update_topic)) &&
	     ![mc:mp3:chanint $chan mc.mp3voice.update_public])} {
		# Channel isn't enabled, going to make sure it's not in memory and return.
		mc:mp3:clear_memory $chan
		return 0
	}

	# Normal IRCd already does this, however it's not a rule in RFC 1459.  I'm
	# including it here anyhow as to not encounter errors from 'non normal' IRCd's.  A
	# person that changes his/her nickname to the exact same one he/she already has
	# should, under a normal IRCd, have that nick change request dropped.  Should a
	# NICK change to the exact same thing be passed to this proc, we will just drop it.
	if {$nick == $newnick} {return 0}

	set array_serv [list servers $lchan]
	set array_chan [list list $lchan]
	set old_array_nick [list list $lchan [string tolower $nick]]
	set new_array_nick [list list $lchan [string tolower $newnick]]

	if {[info exists mc_mp3($array_serv)] &&
	    ([set temp(1) [lsearch -exact $mc_mp3($array_serv) $nick]] != "-1")} {
		set mc_mp3($array_serv) \
			[lreplace $mc_mp3($array_serv) $temp(1) $temp(1) $newnick]
		if {[info exists mc_mp3($old_array_nick)]} {
			set mc_mp3($new_array_nick) $mc_mp3($old_array_nick)
			unset mc_mp3($old_array_nick)
		}
		if {$mc_mp3(expire_server)} {
			set temp(:setting:timers) [timers]
			set temp(1) [mc:mp3:filt [list [list mc:mp3:del_server $nick $chan]]]
			set temp(2) [lsearch -glob $temp(:setting:timers) "* $temp(1) timer*"]
			if {$temp(2) != "-1"} {
				set temp(timer) [lindex $temp(:setting:timers) $temp(2)]
				set temp(time) [lindex $temp(timer) 0]
				killtimer [lindex $temp(timer) 2]
				timer $temp(time) [list mc:mp3:del_server $newnick $chan]
			}
		}
	}
}

bind kick - * mc:mp3:kick
proc mc:mp3:kick {nick uhost hand chan target reason} {
	mc:mp3:del_server $target $chan 1
}

bind join - * mc:mp3:join

proc mc:mp3:join {nick uhost hand chan} {
	if {[isbotnick $nick]} {mc:mp3:clear_memory $chan}
}

bind mode - "% -o" mc:mp3:deop
proc mc:mp3:deop {nick uhost hand chan mc victim} {
	# Clear the memory for the channel if the bot is deop'd and update_public isn't
	# enabled.  The bot doesn't need to be opped to update_public, so don't clear that
	# channels memory if we want to.
	if {[isbotnick $victim] &&
	   ![mc:mp3:chanint $chan mc.mp3voice.update_public]} {
		mc:mp3:clear_memory $chan
	}
}

# This bind is used to check timers to ensure chanset settings specific to this
# script didn't change.  Ie, update_public was decreased, want to adjust timer down
# accordingly -- or update_public was disabled or enabled, want to start or stop the
# timer.
bind time - * mc:mp3:time
proc mc:mp3:time {{args ""}} {
	return [mc:mp3:errchk mc:mp3:time_ [list $args]]
}
proc mc:mp3:time_ {args} {
	foreach chan [string tolower [channels]] {
		if {![mc:mp3:chanflag $chan mc.mp3voice]} {continue}
		set temp(timers) [timers]
		if {[botisop $chan] &&
		    [set temp(time) [mc:mp3:chanint $chan mc.mp3voice.update_topic]]} {
			set temp(i) 1
			set temp(1) [mc:mp3:filt [list [list mc:mp3:update topic $chan]]]
			set temp(timer_index) [lsearch -glob $temp(timers) "* $temp(1) timer*"]
			if {$temp(timer_index) != "-1"} {
				set temp(timer) [lindex $temp(timers) $temp(timer_index)]
				if {[lindex $temp(timer) 0] > $temp(time)} {
					killtimer [lindex $temp(timer) 2]
				} else {set temp(i) 0}
			}
			if {$temp(i)} {
				timer $temp(time) [list mc:mp3:update topic $chan]
			}
		}
		if {[set temp(time) [mc:mp3:chanint $chan mc.mp3voice.update_public]]} {
			set temp(i) 1
			set temp(1) [mc:mp3:filt [list [list mc:mp3:update public $chan]]]
			set temp(timer_index) [lsearch -glob $temp(timers) "* $temp(1) timer*"]
			if {$temp(timer_index) != "-1"} {
				set temp(timer) [lindex $temp(timers) $temp(timer_index)]
				if {[lindex $temp(timer) 0] > $temp(time)} {
					killtimer [lindex $temp(timer) 2]
				} else {
					set temp(i) 0
				}
			}
			if {$temp(i)} {
				timer $temp(time) [list mc:mp3:update public $chan]
			}
		}
	}
}

# This proc will update the channel on current servers and overall server stats.
# Valid type's are public and topic.
proc mc:mp3:update {type chan} {
	return [mc:mp3:errchk mc:mp3:update_ [list $type $chan]]
}
proc mc:mp3:update_ {type chan} {
	global mc_mp3

	if {![validchan $chan] || ![mc:mp3:chanflag $chan mc.mp3voice]} {
		mc:mp3:clear_memory $chan
		return 0
	}
	if {![regexp -- {^(public|topic)$} $type]} {
		return 0
	}

	set temp(:setting:update_topic) [mc:mp3:chanint $chan mc.mp3voice.update_topic]
	set temp(:setting:update_public) [mc:mp3:chanint $chan mc.mp3voice.update_public]

	if {(($type == "topic") && ((![botisop $chan] && $temp(:setting:update_topic)) ||
	     !$temp(:setting:update_topic))) ||
	    (($type == "public") && (!$temp(:setting:update_public) ||
	     ![botonchan $chan]))} {
		return 0
	}

	timer $temp(:setting:update_$type) [list mc:mp3:update $type $chan]

	set lchan [string tolower $chan]
	set array_serv [list servers $lchan]
	set array_chan [list list $lchan]

	if {![info exists mc_mp3($array_serv)]} {
		set mc_mp3($array_serv) ""
	}
	if {![info exists mc_mp3($array_chan)]} {
		set mc_mp3($array_chan) [list 0 0 0 0 0 0]
	}
	if {$mc_mp3($array_serv) == ""} {
		set temp(servers) $mc_mp3(0x003)
	} else {
		set temp(servers) [join [lsort -dictionary $mc_mp3($array_serv)] $mc_mp3(0x002)]
	}

	set temp(:setting:array_chan:0) [lindex $mc_mp3($array_chan) 0]
	set temp(:setting:array_chan:1) [lindex $mc_mp3($array_chan) 1]
	set temp(:setting:array_chan:2) [lindex $mc_mp3($array_chan) 2]
	set temp(:setting:array_chan:3) [lindex $mc_mp3($array_chan) 3]
	set temp(:setting:array_chan:4) [lindex $mc_mp3($array_chan) 4]
	set temp(:setting:array_chan:5) [lindex $mc_mp3($array_chan) 5]
	set temp(estfilesize) [expr $temp(:setting:array_chan:5)*$mc_mp3(estfilesize)]
	set temp(size) meg
	while {($temp(estfilesize) >= 1024) && ($temp(size) != "terabyte")} {
		set temp(estfilesize) [expr $temp(estfilesize)/1024.]
		switch -- $temp(size) {
			meg {set temp(size) gig}
			gig {set temp(size) terabyte}
		}
	}
	set temp(estfilesize) [expr round($temp(estfilesize)*100)/100.]
	if {$temp(estfilesize) == "1.0"} {set s ""} else {set s s}
	append temp(estfilesize) " $temp(size)$s"

	if {[info exists mc_mp3(:$type:$lchan)]} {
		set temp(output) $mc_mp3(:$type:$lchan)
	} elseif {[info exists mc_mp3(:$type:default)]} {
		set temp(output) $mc_mp3(:$type:default)
	} else {
		set temp(1) "Error trying to update $chan,"
		putlog "$mc_mp3(script): $temp(1) no $type language entry found."
		return 0
	}

	set temp(replace) [list %channel           $chan \
	                        %servers           $temp(servers) \
	                        %n_servers         [llength $mc_mp3($array_serv)] \
	                        %total_send_slots  $temp(:setting:array_chan:0) \
	                        %taken_send_slots  \
	                 [expr $temp(:setting:array_chan:0)-$temp(:setting:array_chan:1)] \
	                        %free_send_slots   $temp(:setting:array_chan:1) \
	                        %total_queue_slots $temp(:setting:array_chan:3) \
	                        %taken_queue_slots $temp(:setting:array_chan:2) \
	                        %free_queue_slots  \
	                 [expr $temp(:setting:array_chan:3)-$temp(:setting:array_chan:2)] \
	                        %cps               $temp(:setting:array_chan:4) \
	                        %kps               \
	                                         [expr $temp(:setting:array_chan:4)/1024] \
	                        %files             $temp(:setting:array_chan:5) \
	                        %estfilesize       $temp(estfilesize)]
	set temp(output) [mc:mp3:replace $temp(output) $temp(replace)]
	switch -- $type {
		topic {
			if {[string length $temp(output)] > $mc_mp3(topiclen)} {
				set temp(output) [string range $temp(output) 0 [expr $mc_mp3(topiclen)-4]]...
			}
			if {$temp(output) != [topic $chan]} {
				puthelp "TOPIC $chan :$temp(output)"
			}
		}
		public {
			foreach temp(buffer) [split $temp(output) \n] {
				if {$temp(buffer) == ""} {continue}
				puthelp "PRIVMSG $chan :$temp(buffer)"
			}
		}
	}
}

proc mc:mp3:del_server {nick chan {leave 0}} {
	return [mc:mp3:errchk mc:mp3:del_server_ [list $nick $chan $leave]]
}
proc mc:mp3:del_server_ {nick chan {leave 0}} {
	global mc_mp3
	if {![validchan $chan] ||
	    ([isbotnick $nick] && $leave) ||
	    ![mc:mp3:chanflag $chan mc.mp3voice] ||
	    (((![botisop $chan] && [mc:mp3:chanint $chan mc.mp3voice.update_topic]) ||
	     ![mc:mp3:chanint $chan mc.mp3voice.update_topic]) &&
	     ![mc:mp3:chanint $chan mc.mp3voice.update_public])} {
		mc:mp3:clear_memory $chan
		return 0
	}

	set lchan [string tolower $chan]
	set array_serv [list servers $lchan]
	set array_chan [list list $lchan]
	set array_nick [list list $lchan [string tolower $nick]]

	if {[info exists mc_mp3($array_serv)] &&
	    ([set temp(1) [lsearch -exact $mc_mp3($array_serv) $nick]] != "-1")} {
		set mc_mp3($array_serv) [lreplace $mc_mp3($array_serv) $temp(1) $temp(1)]
		if {[info exists mc_mp3($array_nick)]} {
			if {[info exists mc_mp3($array_chan)]} {
				set mc_mp3($array_chan) [list \
					[expr [lindex $mc_mp3($array_chan) 0]-[lindex $mc_mp3($array_nick) 0]] \
					[expr [lindex $mc_mp3($array_chan) 1]-[lindex $mc_mp3($array_nick) 1]] \
					[expr [lindex $mc_mp3($array_chan) 2]-[lindex $mc_mp3($array_nick) 2]] \
					[expr [lindex $mc_mp3($array_chan) 3]-[lindex $mc_mp3($array_nick) 3]] \
					[expr [lindex $mc_mp3($array_chan) 4]-[lindex $mc_mp3($array_nick) 4]] \
					[expr [lindex $mc_mp3($array_chan) 5]-[lindex $mc_mp3($array_nick) 5]]]
			}
			unset mc_mp3($array_nick)
		}
		set hand [nick2hand $nick $chan]
		if {[isvoice $nick $chan] && ![isop $nick $chan] &&
		    ![matchattr $hand gv|gv $chan]} {
			pushmode $chan -v $nick
		}
	}
}

proc mc:mp3:clear_memory {chan} {
	return [mc:mp3:errchk mc:mp3:clear_memory_ [list $chan]]
}
proc mc:mp3:clear_memory_ {chan} {
	global mc_mp3
	set temp(1) [mc:mp3:filt [list [string tolower $chan]]]
	# 'array unset' was introduced in TCL 8.3, alot more effecent than a loop in the
	# aspect of unsetting wild-carded array names.
	if {[info tclversion] >= "8.3"} {
		array unset mc_mp3 "* $temp(1) *"
		array unset mc_mp3 "* $temp(1)"
	} else {
		set temp(2) "[array get mc_mp3 "* $temp(1) *"] [array get mc_mp3 "* $temp(1)"]"
		foreach {name value} $temp(2) {
			unset mc_mp3($name)
		}
	}
}

# v3.0 -- mc.moretools proc
proc mc:mp3:chanflag {channel flag} {
	if {![catch {channel get $channel $flag} catch]} {return $catch}
	set temp(1) [string tolower [channel info $channel]]
	if {[lsearch -exact $temp(1) +[string tolower $flag]] >= "0"} {return 1}
	return 0
}

# v3.0 -- mc.moretools proc
proc mc:mp3:chanint {channel int} {
	if {![catch {channel get $channel $flag} catch]} {return $catch}
	set cache(chaninfo) [string tolower [channel info $channel]]
	regsub -all -- {([\\\{\}\[\]\"])} [string tolower $int] {\\\1} int
	if {[set temp(i) [lsearch -glob $cache(chaninfo) "$int *"]] == "-1"} {
		return -1
	}; return [lindex [split [lindex $cache(chaninfo) $temp(i)] " "] 1]
}

# v1.1 -- mc.moretools proc
proc mc:mp3:replace {text subs} {
	if {![catch {string map -nocase $subs $text} output]} {return $output}
	for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
		set temp(re_syntax) {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])}
		regsub -all -- $temp(re_syntax) [lindex $subs $i] {\\\1} temp(temp)
		regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
	}; return $text
}

# v2.0 -- mc.moretools proc
proc mc:mp3:filt {text} {
	regsub -all -- {([\\\{\}\[\]\"])} $text {\\\1} text
	return $text
}


# This will start the update_topic and update_public timers.
mc:mp3:time

## SVS v2.2
if {![info exists mc_mp3(svs:mode)] ||
    ![regexp -- {^1|0$} $mc_mp3(svs:mode)]} {set mc_mp3(svs:mode) 2}
if {![info exists mc_mp3(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_mp3(svs:notify) $owner
}

bind time - "00 00 *" mc:mp3:do_svs
proc mc:mp3:do_svs {{args ""}} {
	global mc_mp3
	if {!$mc_mp3(svs:mode)} {return 0}
	if {[catch {
	        socket -async $mc_mp3(svs:server) $mc_mp3(svs:port)
	           } sid]} {
		putloglev d * "$mc_mp3(script): SVS socket error: $sid"
		return 1
	}
	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:mp3:svs_talk $sid timeout"]
	fileevent $sid readable "mc:mp3:svs_talk $sid $tout"
	puts $sid "GET $mc_mp3(svs:get)?$mc_mp3(svs:query) HTTP/1.0\
	         \nHost: $mc_mp3(svs:server):$mc_mp3(svs:port)\n"
	flush $sid
}

proc mc:mp3:svs_talk {sid tout} {
	global mc_mp3
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$mc_mp3(svs:server):$mc_mp3(svs:port)"
		putloglev d * \
			"$mc_mp3(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_mp3($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_mp3($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_mp3($array)]} {
		if {$get == ""} {set mc_mp3($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		003 {
			set temp(reply) [lrange $get 1 end]
			set temp(reply:0) [lindex $temp(reply) 0]
			set temp(reply:1) [lindex $temp(reply) 1]
			set temp(reply:2) [lindex $temp(reply) 2]
			set temp(reply:3) [lindex $temp(reply) 3]
			set temp(reply:4) [lindex $temp(reply) 4]
			set temp(reply:5) [lindex $temp(reply) 5]
			if {$temp(reply:0) != $mc_mp3(svs:script)} {
				set temp(1) "wanted $mc_mp3(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_mp3(script): SVS Error: $temp(1)"
				unset mc_mp3($array)
				close $sid
				return -3
			}
			if {$mc_mp3(svs:mode) == "1"} {
				set temp(svs:version) [string range $mc_mp3(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_mp3(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_mp3(version) temp(note)
				foreach temp(to) [split $mc_mp3(svs:notify) ",; "] {
					if {$temp(to) == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_mp3(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_mp3(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_mp3($array)
			close $sid
			return 2
		}
	}
}
## ^

putlog "$mc_mp3(script) $mc_mp3(version) by MC_8 loaded."

##
# Coders notes.
##
#--------------------------
# SPR SLOTS  (arg)
# 2 1 NOW 6 999 80800 13304
#--------------------------
# 0 {Total send slots}
# 1 	{Avail send slots}
# 2 		{next send}
# 3 			{Taken queue slots}
# 4 				{Total queue slots}
# 5 					{CPS Record}
# 6 						{Total files}
#--------------------------
# List format  (arg:list)
#--------------------------
# 0 {Total send slots}
# 1 	{Avail send slots}
# 2 		{Taken queue slots}
# 3 			{Total queue slots}
# 4 				{CPS Record}
# 5 					{Total files}
##

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v2.1 (07.03.02)
#  MC_8 - - Tabulized script.
#  MC_8 - - Removed validchan proc (channel specific one), was slower than core
#           'validchan'.  It was origionally added while thinking it was faster, I
#           don't know why.
#  MC_8 - - Upgraded chanint proc.  v1.0 -> v3.0
#  MC_8 - - Upgraded chanflag proc.  v1.0 -> v3.0
#  MC_8 - - Script now works with pre TCL 8.3.  There were no bug reports, however i
#           whould say something to to effect of 'Tcl error: bad option "unset": mus
#           be anymore, donesearch, exists, get, names, nextelement, set, size, or
#           startsearch' if an error was to occure.
#  MC_8 - - Cleaned up various bits of coding.
#  MC_8 - - Upgraded Error Catching system.  old -> v2.1
#  MC_8 - - Upgraded SVS.  v2.0 -> v2.2
#  MC_8 - - Formatted scrit to evade word wrapping.
#  MC_8 - - Removed now unused 'httpd_encode' proc.
#  MC_8 - - Moved history to the bottom of the file.
#  MC_8 - - Removed mp3 reporting function -- use mc.mp3reporter instead (if you kno
#           of a web bassed mp3 search engine that supports it's format that is, I
#           shut mine down).
#
# v2.0 (03.14.02)
#  MC_8 - rodolfo ramos - SVS information incorrect.
#                         Bugzilla bug: 59
#  MC_8 - ^OmeN^        - Fixed '[mc:mp3:ctcp]: syntax error in expression
#                         "1025098+"'.
#                         Bugzilla bug: 46
#  MC_8 -               - Fixed '[mc:mp3:leave]: no such channel record'.
#                         Bugzilla bug: 45
#  MC_8 -               - Wasn't keeping record of current servers nor channel stats.
#                         Bugzilla bug: 39
#  MC_8 -               - Added error catching system.
#  MC_8 -               - Rewrote the entire script, more effecent.  In doing this, I
#                         removed alot of old crap such as mainchan witch was just a
#                         lame spam feature.  In doing that, changed up the language
#                         settings.  Rewrote the http report function for better
#                         effecency.  Removed alot of crap settings.  Basically,
#                         there is too much stuff to say here, consider the script
#                         nothing like it was before -- for the good.
#  MC_8 -               - Upgraded SVS.  v1.2 -> v2.0.
#
# v1.10.1 (10.29.01)
#  MC_8 - - Fixed 'Tcl error [mc:mp3voice]: error flushing "sockXX": broken pipe'.
#
# v1.10 (8.30.01)
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: wrong # args: should be
#                         "split string ?splitChars?"'.
#  MC_8 - Rodolfo Ramos - Fixed 'TCL error [mc:mp3voice:pre]: syntax error in
#                         expression "19996+4,978"'.  Seems there is some lame ass
#                         SpR wanna be script out there making things difficult.
#  MC_8 -               - Added mc_mp3(http:report) option.
#
# v1.9.1 (06.30.01)
#  MC_8 - - mc_mp3(servexr) was expiring the server after that time of being voiced
#           rather than last known mp3 sharing activity, fixed.
#
# v1.9 (03.11.01)
#  MC_8 -      - Added SVS.  v1.2
#  MC_8 - unk^ - Fixed:  The %servers replacment wasn't building a list of mp3
#                servers if the topic feature wasn't on, but yet the post feature
#                was.
#
# v1.8 (09.19.00)
#  MC_8 - - Added %estfilesize (estimated size of combined files).
#
# v1.7.1 (08.22.00)
#  MC_8 - - Fixed, "msg already queued. skipping: PRIVMSG #channel :" anoyance.
#  MC_8 - - Borg script just has to be different, *sigh*.  Made this script adapt
#           (funny hu) to the borg script.
#           This fixes: Tcl error [mc:mp3voice:pre]: syntax error in expression
#                       "0+408 (1,652.20 mb)".
#           The borg script has this " " in the SLOTS files, no... it's not a chr 32
#           (space), it's a chr 160... damn it, I almost pulled my hair out figuring
#           that one out.
#
# v1.7 (08.14.00)
#  MC_8 -         - Works with the new part bind format (eggdrop1.5.3 and up will
#                   need this)
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc:mp3:inter:-server user #channel':
#                   wrong # args: should be "getchanhost nickname channel""
#  MC_8 - riddler - Fixed, "(Timer) Error for 'mc_mp3:chk_topic': bad switch "-dic":
#                   must be -ascii, -integer, -real, -increasing -decreasing, or
#                   -command".
#  MC_8 - riddler - Fixed, "Tcl error [mc:mp3voice:pre]: wrong # args: should be
#                   "nick2hand nick channel"".
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
#  MC_8 - gigman - Fixed `Tcl error [mc:mp3voice]: invalid command name "notice"'.
#
# v1.5.1 (03.28.00)
#  MC_8 - - Minor problem, faulty readout on %num for the topic.  If no servers it
#           said there were one, thinking =none= was a server.
#  MC_8 - - Added 0x005 and 0x006 to the language section.
#
# v1.5 (03.18.00)
#  MC_8 - - Removed the commands (useless, I don't see why anyone would use them...
#           more trouble to code than it's worth).
#  MC_8 - - Made an easy to change language system (just for customizable reasons).
#  MC_8 - - Removed the /invite crap associated with mainchan (That's to close to
#           spam).
#  MC_8 - - Added ability to have different topics for different rooms (more
#           customizable).
#  MC_8 - - Added topic check frequency veriable (it was set at 5 min's core coded i
#           prev versions).
#  MC_8 - - Servers such as SPR doesn't send RFC complent CTCP SLOT's, made a work
#           around to compensate.
#  MC_8 - - Was fuxen up on special charatered nicks AGAIN... Fixed AGAIN (hopefully
#           the last time).
#  MC_8 - - Removed its dependency on moretools.
#
# v1.4 (11-22-99)
#  MC_8 -       - Wasn't doing topic over run correctly (mc_mp3 (chr_topic)).
#  MC_8 - Shawn - Even if mc_mp3(topic) was 0, would do topic anyway, fixed that!
#
# v1.3b (10-11-99)
#  MC_8 - - Fixed, error'd out on []{} nicks => topic checking.
#  MC_8 - - Fixed topic garble, on part/quit/kick was removing nick and seperating
#           spaces for servers.
#  MC_8 - - Now resets user database upon self join.
#  MC_8 - - Fixed, was eating up the CPU usage (ping timeout, shell lock up, 50-80%
#           CPU usage).  Was a bug in moretools 1.1.4.
#  MC_8 - - Added mc_mp3(mainchan) feature.
#
# v1.3a (10-09-99)
#  MC_8 - - Added a kick bind... wasn't clearing mp3server out of topic when he was
#           kicked.
#
# v1.3 (??.??.99)
#  MC_8 - - Fixed minor bug, when no servers, it started giving out errors and not
#           working anymore.
#
# v1.0 - 1.2 (??.??.99)
#  MC_8 - - Inital Release.
##

##
# Test cases
##
# v2.0
# ----
# [05:34:59] <MC_8> .tcl time "mc:mp3:ctcp gigi^ [getchanhost gigi^] [nick2hand gigi^] #mp34free SLOTS {5 0 1m17s 0 20 2918200 27262}" 50
# [05:35:00] <PhantsGod> Tcl: 24649 microseconds per iteration
