Date: Tue, 17 Aug 1999 02:29:37 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] care about the age of the pte even if we are low on
 memory
In-Reply-To: <Pine.LNX.4.10.9908091244590.7493-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908170228430.16783-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Conway <nconway.list@ukaea.org.uk>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Aug 1999, Andrea Arcangeli wrote:

>On Mon, 9 Aug 1999, Neil Conway wrote:
>
>>Ouch - let's try to keep those comments up to date folks.  Good comments
>
>You are plain right, excuse me (I have not read the comment). When the
>patch will be applyed I'll provide an update to the comment. Thanks for
>pointing this out.

As Neil pointed out I have not updated the comment, please apply to
2.3.13:

--- 2.3.13/mm/vmscan.c	Thu Aug 12 02:53:26 1999
+++ /tmp/vmscan.c	Tue Aug 17 02:28:09 1999
@@ -50,10 +50,7 @@
 	if (pte_val(pte) != pte_val(*page_table))
 		goto out_failed_unlock;
 
-	/*
-	 * Dont be too eager to get aging right if
-	 * memory is dangerously low.
-	 */
+	/* Don't look at this pte if it's been accessed recently. */
 	if (pte_young(pte)) {
 		/*
 		 * Transfer the "accessed" bit from the page

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
