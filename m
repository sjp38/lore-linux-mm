Date: Mon, 1 Dec 2008 00:37:37 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 0/8] badpage: more resilient bad page pte and rmap
Message-ID: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a batch of 8 mm patches, intended for 2.6.29: revisiting
bad_page() and print_bad_pte() and the page_remove_rmap() Eeek BUG.
Diffed to slot in to the mmotm series just before "mmend".

The only clash with later mmotm patches is with Manfred's
mm-debug-dump-pageframes-on-bad_page.patch
which puts a hexdump in there.  Trivial to fix up, but I've never
actually found that patch helpful - perhaps because it isn't an -mm
tree that "Bad page state" reporters are running.  Time to drop it?

 include/linux/page-flags.h |   25 ++------
 include/linux/rmap.h       |    2 
 include/linux/swap.h       |   12 ---
 mm/filemap_xip.c           |    2 
 mm/fremap.c                |    2 
 mm/internal.h              |    1 
 mm/memory.c                |  109 ++++++++++++++++++++++++++---------
 mm/page_alloc.c            |  108 +++++++++++++++++++---------------
 mm/rmap.c                  |   24 -------
 mm/swapfile.c              |    7 +-
 10 files changed, 166 insertions(+), 126 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
