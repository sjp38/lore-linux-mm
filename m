Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA07297
	for <linux-mm@kvack.org>; Fri, 3 Jul 1998 10:19:01 -0400
Date: Fri, 3 Jul 1998 12:11:14 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Kswapd-problems (?)
In-Reply-To: <91F2D41BEDADD1119DCC0060B06D7BD10A0C4F@dserver.fleggaard.dk>
Message-ID: <Pine.LNX.3.96.980703120910.13344A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Brian Schau <bsc@fleggaard.dk>
Cc: "'linux-kernel@vger.rutgers.edu'" <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Jul 1998, Brian Schau wrote:

> PID USER     PRI  NI SIZE  RES SHRD STAT %CPU %MEM  TIME COMMAND
>   3 root       4 -12    0    0    0 RW<  99.9  0.0738:01 kswapd
> 
> Why does 'kswapd' use so much resources?    And why has it used so many
> resources during the night?

This is certainly a rare thing to happen. My best
guess would be that you ran out of virtual
memory and the system tried to go on anyway...

Some output from /bin/free, procinfo and vmstat
plus some info on what type of machine and
workload you have would be useful to determine
the exact cause of this problem.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
