From: Bernardo Innocenti <bernie@develer.com>
Subject: Fwd: uClinux 2.6.x memory allocator brokenness
Date: Sun, 17 Aug 2003 18:10:20 +0200
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200308171810.20781.bernie@develer.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

even though this is an uClinux related question, perhaps it would
be best answered by the mm people since it requires in-depth knowledge
of the page allocator.

----------  Forwarded Message  ----------

Subject: uClinux 2.6.x memory allocator brokenness
Date: Saturday 16 August 2003 22:45
From: Bernardo Innocenti <bernie@develer.com>
To: uClinux development list <uclinux-dev@uclinux.org>
Cc: David McCullough <davidm@snapgear.com>, Greg Ungerer <gerg@snapgear.com>

Hello,

not sure if anybody else experienced this problem. 2.5.x/2.6.x
kernels seem to have some nasty bug in mm/page_alloc.c.

When I allocate over 256KB of memory, the allocator steps into
__alloc_pages() with order=7 and finds nothing free in the 512KB
slab, then it splits the 1MB block in two 512MB blocks and fails
miserably for some unknown reason.

I also noticed that any allocation (even smaller ones) always
fail in the fast path and falls down into the slowish code
that wakes up kswapd to free some more pages.

This happens because zone->pages_low is set to 512 while
free_pages is consistently below 400 on my system.

Perhaps these values would have to be retuned on embedded targets.

--
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/

Please don't send Word attachments -
 http://www.gnu.org/philosophy/no-word-attachments.html

-------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
