Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA07568
	for <linux-mm@kvack.org>; Fri, 3 Jul 1998 11:15:40 -0400
Date: Fri, 3 Jul 1998 17:14:24 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: SV: Kswapd-problems (?)
In-Reply-To: <91F2D41BEDADD1119DCC0060B06D7BD10A0C67@dserver.fleggaard.dk>
Message-ID: <Pine.LNX.3.96.980703170541.20458F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Brian Schau <bsc@fleggaard.dk>
Cc: "'linux-kernel@vger.rutgers.edu'" <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Jul 1998, Brian Schau wrote:

> Ok ... here are some stats:

> enjoy!bsc $ free
>              total       used       free     shared    buffers
> cached
> Mem:        515728     388652     127076      22668     170736
> Swap:       128516        112     128404     182160
> 
> enjoy!bsc $ vmstat
>  procs                  memory    swap        io    system         cpu
>  r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
>  0 0 1   112 127188 170736 182156   0   0   14   27  130   62  17  40 43

OK, looking great... Just a bit lightly-loaded, with 43% idle
the second processor board wasn't really needed yet...

> enjoy!bsc $ cat stat
> 
> cpu  48424 4866113 11279880 12076191
> cpu0 1815 0 6984201 81636
> cpu1 6414 1129198 2255511 3676529
> cpu2 3393 952942 2040168 4071149
> cpu3 0 0 0 7067652

> (cpu3 - the fourth processer - has been idle since yesterday evening?
> Even though we have loaded the machine very much (loadavg > 100  ;o))

It has been idle since boot. I think this means you supplied
the machine with _I/O_ load and bought CPUs instead of disks...

> Output from 'top':
> 
>   4:38pm  up 19:36h, 10 users,  load average: 1.76, 1.50, 1.65
> 62 processes: 60 sleeping, 2 running, 0 zombie, 0 stopped
> CPU  states:  4.3% user, 32.5% system, 11.8% nice, 63.1% idle
> CPU0 states:  0.0% user, 99.1% system,  0.0% nice,  0.2% idle
> CPU1 states:  0.0% user, 31.2% system,  2.0% nice, 66.1% idle
> CPU2 states:  0.0% user, 29.1% system,  3.2% nice, 67.0% idle
> CPU4 states:  0.0% user,  0.0% system,  0.0% nice, 100.0% idle
> 
> (load average is non-typical ... it's usually > 3)

It is _very_ non-typical. 0% of time spent in user mode and
150% spent in system mode. What the heck is that box doing
anyway???

> The process giving me headaches:
> 
>     USER   PID CP LP %CPU %MEM  NI   VSZ   RSS  SHRD  TT STAT   TIME
> COMMAND
> root       3  0  0 99.6  0.0 -12   0     0     0  ?  RW<  19:17h kswapd

OK, this gives me headaches too...

> I can supply you with more information - just say what kind of info you
> need ...

For now, I'm mainly worried about the _huge_ amount of buffer
memory your box is using. It has 180M of buffer memory, which
it needs to scan regularly for deciding which buffers to write
out. OTOH, with 120M free, kswapd shouldn't be running at all...

My guess is that something strange happened and that kswapd
hasn't recovered yet (although it should have)...

I would like some info on exactly what the box was running
at the moment kswapd flipped out... Also, some info on what
the box usually runs, what I/O subsystem it has and what
kind of network interface and other misc stuff is hanging
from it would be great.

grtz,

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
