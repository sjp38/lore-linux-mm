Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ap.ccr.net [208.130.159.16])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12286
	for <linux-mm@kvack.org>; Tue, 18 May 1999 10:03:54 -0400
Subject: Q: PAGE_CACHE_SIZE?
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 May 1999 09:03:57 -0500
Message-ID: <m1yaimzd82.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Who's idea was it start the work to make the granularity of the page
cache larger?

>From what I can tell:
(a) It can save on finding multiple pages
(b) allows larger internal fragmentation of memory.
(c) Isn't needed if you just need a large chunk of the page
    cache at a time.  (It isn't hard to tie 2 or more pages to
    together if you need to).

This is something I'm stumbling over porting patches for large
files in the page cache from 2.2.5 to to 2.3.3.

I guess if it's worth it I would like to talk with whoever is
responsible so we can coordinate our efforts.  

Otherwise I would like this code dropped. 

Non-page cache aligned mappings sound great until you
(a) squeeze the extra bits out of the vm_offset and make it an index
into the page cache, and
(b) realize you need more bits to say how far you are into a page.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
