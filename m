Date: Sat, 16 Sep 2000 21:20:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] update to new VM
Message-ID: <Pine.LNX.4.21.0009162114080.1051-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.redhat.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Linus,

after increasing the test base, the following 2 problems have
been noticed with the VM patch, and are (hopefully) fixed in
this patch:

1)  if __alloc_pages() is called without __GFP_IO in the
    gfp_mask, we cannot wait for kswapd
        -> use try_to_free_pages() the oldfashioned way instead
1b) while fixing up the other __GFP_IO problems, I noticed
    programs at schedule points in the VM, sleeping in S state,
    this is fixed by explicitly making them runnable
2)  the VM was badly balanced for low-memory (8MB) machines,
    this has been fixed by making it easier for kswapd to go
    to sleep in refill_inactive() and by waking up kswapd earlier
    at the top of __alloc_pages()

I'm still not 100% sure if this patch is completely correct,
but it fixes one serious bug in the current VM inside -test9-pre1
and I'm leaving for Linux Kongress tomorrow so this is my last
chance to post anything for the next few days ;(

If this patch proves stable for everyone and makes 8MB machines
workable again with the new VM, please include this in the next
pre-patch. If it doesn't work correctly, I'll somehow find it
in my email while at Linux Kongress and I'll prepare a new fix.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
