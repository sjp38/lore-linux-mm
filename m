Received: from UNIX49.andrew.cmu.edu (UNIX49.andrew.cmu.edu [128.2.13.179])
	(user=aeswaran mech=GSSAPI (0 bits))
	by smtp2.andrew.cmu.edu (8.12.10/8.12.10) with ESMTP id i1RG3pn6009448
	for <linux-mm@kvack.org>; Fri, 27 Feb 2004 11:03:51 -0500
Date: Fri, 27 Feb 2004 11:03:50 -0500 (EST)
From: Anand Eswaran <aeswaran@andrew.cmu.edu>
Subject: Doubt regarding kswapd
Message-ID: <Pine.LNX.4.58-035.0402271047590.3342@unix49.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

    Im using the 2.4.18 kernel version for implementing
reservation of pages for selective applications.

    In the kswapd loop, I noted that the do_try_to_free_pages, the
page_launder loop is executed before the refill_inactive or the
refill_freelist.

  When a page is added to the pagecache for the first time , it is added
to the active list. So it seems to me that if it is the very first time
kswapd executes, kswapd is guaranteed to skip its laundering loop (
because the list is empty) since refill_inactive_list() which is
responible for populating the inactive_dirty_list() has not executed yet.

  Is there anything Im missing that necessitates the page_launder loop
coming first? I guess one explanation could be when kswapd() is called,
you need pages real quick, so it might be logical to execute that loop
before running through the other lists.

  Could someone please explain the true rationale.

  In particular, would an implementation with refill_inactive_list() before page_launder()
in the do_try_to_free_pages()  be wrong? ( this is not a quibble,
it really matters to my design)

Thanks a lot,
----
Anand.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
