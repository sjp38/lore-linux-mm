Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA17390
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 09:37:48 -0500
Date: Sun, 24 Jan 1999 14:28:31 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <Pine.LNX.3.96.990124141300.222A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990124142635.476A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Sun, 24 Jan 1999, Andrea Arcangeli wrote:

> Here the fix:

Woops the fix was wrong, I forgot that there was a not needed check due me
(just removed from some weeks here, and that's because I forget to
remove it now ;):

The complete fix is this. Excuse me...

Index: vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 vmscan.c
--- vmscan.c	1999/01/23 18:52:32	1.1.1.3
+++ vmscan.c	1999/01/24 13:26:24
@@ -325,11 +325,9 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = nr_tasks / (priority+1);
+	counter = (nr_tasks << 1) / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
-		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
 		assign = 0;



Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
