Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA15534
	for <linux-mm@kvack.org>; Wed, 25 Feb 1998 17:17:15 -0500
Date: Wed, 25 Feb 1998 23:15:11 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Message-ID: <Pine.LNX.3.91.980225230741.1545A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've just come up with a very simple idea to limit
thrashing, and I'm asking you if you want it implemented
(there's some cost involved :-( ).

We could simply prohibit the VM subsystem from swapping
out pages which have been allocated less than one second
ago, this way the movement of pages becomes 'slower', and
thrashing might get somewhat less.

The cost involved is that we have to add a new entry
to the page_struct :-( and do some (relatively cheap)
bookkeeping on every page. Also, this might limit the
rate of allocation some programs do, giving rise to
all sorts of new and exiting problems.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
