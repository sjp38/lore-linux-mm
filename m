Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA20799
	for <linux-mm@kvack.org>; Thu, 5 Mar 1998 16:24:43 -0500
Date: Thu, 5 Mar 1998 22:22:21 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: swapout frenzy solution
Message-ID: <Pine.LNX.3.91.980305221552.448A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've just come up with a simple 'solution' for the swapout
frenzy experienced by the recent free_memory_available()
test in kswapd.

We simply stop kswapd when nr_free_pages > free_pages_high * 4.
Since page allocation always assigns a page from the smallest
possible unit, the larger free areas are extremely likely to
grow bigger and bigger, especially when nr_free_pages is very
large, say > 3 * free_pages_high.

Since my vmscan.c is somewhat different from yours, and since
I don't know what you have done to it in the last week, I
won't send you a diff.

(trying to merge a faulty diff is _far_ more work than
doing the 30 second edit yourself :-)

I'm trying it now, and I don't see any swapout frenzies
occurring anymore...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
