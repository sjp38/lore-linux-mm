Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA17954
	for <linux-mm@kvack.org>; Wed, 4 Mar 1998 12:01:01 -0500
Received: from mirkwood.dummy.home (root@anx1p6.fys.ruu.nl [131.211.33.95])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id SAA24937
	for <linux-mm@kvack.org>; Wed, 4 Mar 1998 18:00:55 +0100 (MET)
Date: Wed, 4 Mar 1998 17:26:26 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: sideeffect of my uPATCH
Message-ID: <Pine.LNX.3.91.980304172206.25705A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I just noticed a sideeffect of the small patch
to vmscan.c that I submitted yesterday.

As was to be expected, linear swapping has gotten
a lot worse than it used to be, mainly because we
now continue our pageout scan where we left, so
it's more likely that we page out something we'll
need again soon (in a linearly swapping program).

I think we should try the linear swap patch (from
Ingo ?) from some time ago. Does anybody know where
it is??? 

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
