Date: Thu, 20 Nov 2008 01:10:07 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 0/7] mm: cleanups
Message-ID: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a batch of 7 mm cleanups, intended for 2.6.29: just assorted
things that have been annoying me.  Three or four slightly more
interesting batches should follow in the days ahead.

Though most of the testing has been against 2.6.28-rc5 and its
precursors, these patches are diffed to slot in to the mmotm series
just before "mmend": that is, before the "memcgroup" changes,
with which there's one trivial clash on 5/7.

 Documentation/filesystems/Locking |    6 -----
 Documentation/filesystems/vfs.txt |   13 ++++++++---
 fs/buffer.c                       |   12 ++++------
 fs/inode.c                        |    4 +--
 include/linux/cgroup.h            |   14 -----------
 include/linux/fs.h                |   10 --------
 include/linux/gfp.h               |    6 -----
 include/linux/page-flags.h        |    1 
 include/linux/rmap.h              |    3 --
 include/linux/swap.h              |    2 -
 kernel/cgroup.c                   |   33 ----------------------------
 kernel/exit.c                     |   16 +++++--------
 mm/memory.c                       |    6 -----
 mm/memory_hotplug.c               |    9 ++-----
 mm/migrate.c                      |    9 +------
 mm/page-writeback.c               |   27 +++++++++-------------
 mm/page_io.c                      |    4 +--
 mm/rmap.c                         |   11 ++++++---
 mm/shmem.c                        |    2 -
 mm/swap.c                         |   19 ----------------
 mm/swap_state.c                   |   19 +++++++---------
 mm/swapfile.c                     |    8 ++----
 mm/vmscan.c                       |   24 +++++++++-----------
 23 files changed, 76 insertions(+), 182 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
