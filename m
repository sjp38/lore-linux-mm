Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA16825
	for <linux-mm@kvack.org>; Thu, 31 Dec 1998 13:42:10 -0500
Date: Thu, 31 Dec 1998 19:34:40 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <Pine.LNX.3.96.981231182534.658A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981231193257.330B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@terrorserver.swansea.linux.org.uk>
Cc: linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Benjamin Redelings I <bredelin@ucsd.edu>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Dec 1998, Andrea Arcangeli wrote:

> Comments?
> 
> Ah, the shrink_mmap limit was wrong since we account only not referenced
> pages.
> 
> Patch against 2.2.0-pre1:

whoops in the last email I forget to change a bit the subject (adding
[patch]) and this printk: 

Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.1.2.43 linux/mm/vmscan.c:1.1.1.1.2.45
--- linux/mm/vmscan.c:1.1.1.1.2.43	Thu Dec 31 17:56:27 1998
+++ linux/mm/vmscan.c	Thu Dec 31 19:41:06 1998
@@ -449,11 +449,7 @@
 	case 0:
 		/* swap_out() failed to swapout */
 		if (shrink_mmap(priority, gfp_mask))
-		{
-			printk("swapout 0 shrink 1\n");
 			return 1;
-		}
-		printk("swapout 0 shrink 0\n");
 		return 0;
 	case 1:
 		/* this would be the best but should not happen right now */



Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
