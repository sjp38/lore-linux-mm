Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA16714
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 08:17:28 -0500
Date: Sun, 24 Jan 1999 14:16:35 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <Pine.LNX.3.96.990123210422.2856A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990124141300.222A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Jan 1999, Andrea Arcangeli wrote:

> On Wed, 20 Jan 1999, Linus Torvalds wrote:
> 
> > In short, before you post a bug-report about 2.2.0-final, I'd like you to
> 
> There are three things from me I think should go in before 2.2.0 real

There's a fourth thing I forget to tell yesterday. If all pte are young we
could not be able to swapout while with priority == 0 we must not care
about CPU aging. I hope to have pointed out right and needed things, I
don't want to spam you while you are busy... 

Here the fix:

Index: vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 vmscan.c
--- vmscan.c	1999/01/23 18:52:32	1.1.1.3
+++ linux/mm/vmscan.c	1999/01/24 13:12:30
@@ -325,7 +325,7 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = nr_tasks / (priority+1);
+	counter = (nr_tasks << 1) / (priority+1);
 	if (counter < 1)
 		counter = 1;
 	if (counter > nr_tasks)


Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
