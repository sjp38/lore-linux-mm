Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA07822
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 19:12:16 -0500
Date: Tue, 3 Mar 1998 00:54:12 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: new kswapd logic
Message-ID: <Pine.LNX.3.91.980303005103.6201A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

with my new free_memory_available() patch, it
should be possible to put in my kswapd logic
patch again.

Besides, since my kswapd logic patch _does_
put a limit on the number of freed pages, and
the old mechanism doesn't, my algoritm should
(in theory) prevent the 'my machine just swapped
out 24 of 48 megs of memory' messages we've been
getting on linux-kernel this weekend.

Linus, I've been testing my new kswapd and
free_memory_available() patches, and they work
better than the original ones, so please put
them in...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
