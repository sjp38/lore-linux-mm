Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA06723
	for <linux-mm@kvack.org>; Fri, 27 Mar 1998 05:03:20 -0500
Date: Fri, 27 Mar 1998 10:03:37 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: new allocation algorithm
Message-ID: <Pine.LNX.3.91.980327095733.3532A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus and Stephen,

I just came up with the idea of using an ext2 like algorithm
for memory allocation, in which we:
- group memory in 128 PAGE groups
- have one unsigned char counter per group, counting the number
  of used pages
- allocate with the goal to fill the busiest group
- penalize pages (page->age) when the group is relatively empty
- thereby shift memory usage from empty groups to full groups, making
  larger allocation in empty groups easier
- PLUS we get rid of the 'randomness' in the current system, where we
  sometimes swap out over half of total memory in one sweep while
  still not reaching our goals

Of course, such an algorithm would be relatively expensive...
But could it be worth it?

Trading off the tradeoffs,

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
