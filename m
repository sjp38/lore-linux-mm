Date: Sun, 23 Nov 2008 21:53:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 0/8] mm: from gup to vmscan
Message-ID: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a batch of 8 mm patches, intended for 2.6.29: a narrative
beginning in __get_user_pages and do_wp_page, centering on swap
cache freeing, and ending in shrink_page_list and add_to_swap.

Though most of the testing has been against 2.6.28-rc5 and its
precursors, these patches are diffed to slot in to the mmotm series
after my 8 cleanups, just before "mmend".  No patch clashes with later,
but 3/8 needs an accompanying fix to memcg-memswap-controller-core.patch.

 Documentation/vm/unevictable-lru.txt |   63 ++++------------
 include/linux/swap.h                 |   21 ++---
 mm/memory.c                          |   31 ++++++--
 mm/page_io.c                         |    2 
 mm/swap.c                            |    3 
 mm/swap_state.c                      |   12 +--
 mm/swapfile.c                        |   96 ++++++++-----------------
 mm/vmscan.c                          |   17 +---
 8 files changed, 96 insertions(+), 149 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
