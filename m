Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA01846
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 08:09:30 -0500
Date: Thu, 26 Mar 1998 14:01:52 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: test [PATCH] 2.1.91pre2 swap clustering
Message-ID: <Pine.LNX.3.91.980326135818.523D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I have some test results on 2.1.91pre2 now. With my patch,
it's a tad agressive, but _extremely_ fast with swapping.
I think it would be wise to reduce the number of tries by
a factor, as in:

-	tries = (50 << 3) >> free_memory_available(3);
+	tries = (50 << 2) >> free_memory_available(3);

The clustered swapout-from-application seems to work fabulously,
since the program moves the disk arm less then it used to.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
