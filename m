Date: Sat, 6 Oct 2007 21:35:58 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 0/7] swapin/shmem patches
Message-ID: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's my belated set of swapin/shmem patches, which I hope might still
be allowed into 2.6.24 after a trial in -mm.

[PATCH 1/7] swapin_readahead: excise NUMA bogosity 
[PATCH 2/7] swapin_readahead: move and rearrange args
[PATCH 3/7] swapin needs gfp_mask for loop on tmpfs
[PATCH 4/7] shmem: SGP_QUICK and SGP_FAULT redundant
[PATCH 5/7] shmem_getpage return page locked
[PATCH 6/7] shmem_file_write is redundant
[PATCH 7/7] swapin: fix valid_swaphandles defect

They're based on 2.6.23-rc8-mm2, but most apply to 2.6.23-rc9 plus
mm-clarify-__add_to_swap_cache-locking.patch
mm-clarify-__add_to_swap_cache-locking-fix.patch
mm-shmemc-make-3-functions-static.patch

The exceptions are 5/7 and 6/7, which assume Nick's aops mods to shmem.c:
implement-simple-fs-aops.patch
implement-simple-fs-aops-fix.patch
3/7 fixes a hang made visible by those mods, but does not depend on them.

 include/linux/swap.h |   19 +--
 mm/memory.c          |   65 -------------
 mm/shmem.c           |  200 +++++++----------------------------------
 mm/swap_state.c      |   59 ++++++++++--
 mm/swapfile.c        |   52 +++++++---
 5 files changed, 135 insertions(+), 260 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
