Received: from localhost (bcrl@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id LAA10395
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 11:21:23 -0500
Date: Thu, 18 Dec 1997 11:21:23 -0500 (EST)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: ideas for a swapping daemon
Message-ID: <Pine.LNX.3.95.971218112022.10225C-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Date: Thu, 18 Dec 1997 15:28:07 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
X-Sender: riel@mirkwood.dummy.home
Reply-To: H.H.vanRiel@fys.ruu.nl
To: linux-mm <linux-mm@kvack.org>
cc: linux-kernel <linux-kernel@vger.rutgers.edu>
Subject: ideas for a swapping daemon
Message-ID: <Pine.LNX.3.91.971218151905.15652C-100000@mirkwood.dummy.home>
Approved: ObHack@localhost
Organization: none
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

THIS FIRST MESSAGE WILL BE ON LINUX-KERNEL, I hope you'll all
F-up to linux-mm ONLY!!!
---------
Hi,

here it is, the thread about the swapping daemon <g>

I have the following ideas about the swapping daemon:

- it should swap out some processes if the paging daemon
  (kswapd) doesn't manage to keep nr_free_pages above
  (min_free_pages + free_pages_low)/2 for some time (ie: 5 seconds)
- then it should choose a low-priority, or long-sleeping program
  and swap it out (using the kswapd swapping mechanism, but using
  a 'force' flag, which could be implemented as an argument to the
  routines).
- as long as buffer+cache memory take up more than 1/3 of memory,
  it should try swapping that memory as well
- after a program has been swapped out, it can be swapped in by:
  - being swapped out some time (in case of a low-prio process swap)
  - being woken up (in case of a sleeping program being swapped out)

This is a very rough outline of what the swapping process should
do, and more ideas are needed...

looking forward to your comments,

Rik.

PS: I'd like this thread to continue on linux-mm only. The
linux-kernel people who'd like to follow it too, can easily
subscribe to linux-mm@kvack.org (majordomo@kvack.org) since
linux-mm tends to a quiet list...
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
