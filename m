Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA18166
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 15:40:25 -0500
Date: Mon, 23 Mar 1998 20:08:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: BIG FAT BUG with free_memory_available()
Message-ID: <Pine.LNX.3.91.980323200337.771B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

it seems like I ran into some big fat bug with
the free_memory_available() test in kswapd.

My system turned into a swap loop with no change
in the amount of free memory and no 128k area free.
Probably this is because there's not one single
128k area without an unswappable page in it.

The only way I see around this is to disallow kernel
memory allocation and locked pages in a certain part
of physical memory, but maybe there's another way...

grtz,

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
