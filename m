Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA04775
	for <linux-mm@kvack.org>; Tue, 10 Mar 1998 12:09:32 -0500
Date: Tue, 10 Mar 1998 16:29:18 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [docPATCH] vm.txt change
Message-ID: <Pine.LNX.3.91.980310162545.20757A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

In the light of 'help, my 32meg system has 60megs of
buffermem' I decided to update
linux/Documentation/sysctl/vm.txt
in order to help out the people who are experiencing
those problems.

And to the people who are experiencing those problems:
RTFM :-)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|       http://www.fys.ruu.nl/~riel/        | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/Documentation/sysctl/vm.txt~	Tue Mar 10 16:24:40 1998
+++ linux/Documentation/sysctl/vm.txt	Tue Mar 10 16:24:40 1998
@@ -164,7 +164,7 @@
 swapctl:
 
 This file contains no less than 16 variables, of which about
-half is actually used :-) In the listing below, the unused
+half are actually used :-) In the listing below, the unused
 variables are marked as such.
 All of these values are used by kswapd, and the usage can be
 found in linux/mm/vmscan.c.
@@ -221,9 +221,12 @@
 
 The values of sc_pageout_weight and sc_bufferout_weight are
 used to control the how many tries kswapd will do in order
-to swapout one page / buffer. As with sc_age_cluster_fract,
-the actual value is calculated by several more or less complex
-formulae and the default value is good for every purpose.
+to swapout one page / buffer. These values can be used to
+finetune the ratio between user pages and buffer/cache memory.
+When you find that your Linux system is swapping out too much
+process pages in order to satisfy buffer memory demands, you
+might want to either increase sc_bufferout_weight, or decrease
+the value of sc_pageout_weight.
 
 ==============================================================
 
