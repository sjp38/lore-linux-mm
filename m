Received: from webmail.andrew.cmu.edu (WEBMAIL2.andrew.cmu.edu [128.2.10.92])
	by smtp1.andrew.cmu.edu (8.12.10/8.12.10) with SMTP id i1G3CtZI007952
	for <linux-mm@kvack.org>; Sun, 15 Feb 2004 22:12:55 -0500
Message-ID: <1165.128.2.185.83.1076901174.squirrel@webmail.andrew.cmu.edu>
Date: Sun, 15 Feb 2004 22:12:54 -0500 (EST)
Subject: Doubt regarding reservation of pages for application
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
Reply-To: aeswaran@ece.cmu.edu
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi :

   Im trying to implement reservation of pages for  particular
applications in the 2.4-18 kernel.

    In this regard, I have a few doubts and would really appreciate if
someone could someone please help me out with these.

    I know its a longer-than-avg mail , sorry about it, just thought
elaborating might throw more light on it.



WHAT I'M DOING

1) I select a particular chunk of the memory ( a subsection of the first
zone[ZONE_NORMAL]) that has  unused pages (not in the pagecache)

2)   I populate pages from this region onto a special freelist structure
of mine ( essentially duplicating the free_area_t )

  I implement this reservation as a system call which takes in the size of
the region in PAGE_SIZE units.


MY QUESTION

  I grab the pagemap_lru_lock early and dont let it go until Ive populated
all the pages in the chosen region to my freelists. The length of time I
grab the lock is proportional to the size of the region Im reserving for
my application.

   Does this affect kswapd operations significantly ? i.e Is it ok to make
kswapd wait till I release the spinlock?

   I recently had a fiasco wherein when journalling support for my ide
device was aborted and page buffers were written randomly to my disk.
Hence my hypothesis on interference with kswapd and jbd. Could one of
the gurus on this list please verify this for me? ;)

  On a meta-level, is there any interest in general for such support for
timing-constrained multimedia applications where you dont want to pay
the timing penalty of a disk swap? If there is, at the end of my
implementation, I can come out with a patch. Please let me know.


Thanks a lot,

-----
Anand.









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
