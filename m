Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 445486B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:31 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:29 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 00/12] mm: fix sparse warnings
Date: Thu, 30 Sep 2010 12:50:09 +0900
Message-Id: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

This patchset tries to remove various warnings from sparse. Each patch
contains the warnings it removes in changelog. I compile-tested with
all{yes,no}config on x86. Any comments would be welcomed.

Thanks.

---

Namhyung Kim (12):
  mm: remove temporary variable on generic_file_direct_write()
  mm: add casts to/from gfp_t in gfp_to_alloc_flags()
  mm: wrap get_locked_pte() using __cond_lock()
  mm: add lock release annotation on do_wp_page()
  mm: wrap follow_pte() using __cond_lock()
  rmap: annotate lock context change on page_[un]lock_anon_vma()
  rmap: wrap page_check_address() using __cond_lock()
  rmap: make anon_vma_[chain_]free() static
  vmalloc: rename temporary variable in __insert_vmap_area()
  vmalloc: annotate lock context change on s_start/stop()
  mm: declare some external symbols
  vmstat: include compaction.h when CONFIG_COMPACTION

 include/linux/backing-dev.h |    1 +
 include/linux/mm.h          |   10 +++++++++-
 include/linux/rmap.h        |   29 ++++++++++++++++++++++++++---
 include/linux/writeback.h   |    2 ++
 mm/filemap.c                |    8 ++++----
 mm/memory.c                 |   16 ++++++++++++++--
 mm/page_alloc.c             |    4 ++--
 mm/rmap.c                   |   10 ++++++----
 mm/vmalloc.c                |   10 ++++++----
 mm/vmstat.c                 |    2 ++
 10 files changed, 72 insertions(+), 20 deletions(-)

--
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
