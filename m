Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA01125
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 05:15:33 -0500
Date: Thu, 26 Mar 1998 11:14:40 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: free_memory_available() is enough?
Message-ID: <Pine.LNX.3.91.980326111309.17947A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I was just wondering... With people complaining (justly) all
over the place that kswapd just swapped out half of their
memory, wouldn't it be better to have a limit on the amount
of memory kswapd _can_ swap out? (let's say 1/8th of memory)

grtz,

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
