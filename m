Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA18163
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 15:40:24 -0500
Date: Mon, 23 Mar 1998 21:24:21 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: vmscan.c loop fix. 
Message-ID: <Pine.LNX.3.91.980323211950.2526A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I think the 'proper' fix for swapout loops would be to limit
the amount of CPU used by kswapd (to 50%?).
We could do that by:
- having kswapd measure it's own CPU usage (over a 30 second period?)
- exiting after 3 jiffies (32 Alpha) max when it's usage is
  above quota and setting a hard_next_swap_jiffies to jiffies + 3

Of course, this has the disadvantage that kswapd can't keep
up with allocation festivities :-(

What do you think?

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
