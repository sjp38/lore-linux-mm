Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D8BD56B0039
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 16:18:04 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1403078pdj.22
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 13:18:04 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/2] fs,mm: abstract i_mmap_mutex lock
Date: Wed,  2 Oct 2013 13:17:44 -0700
Message-Id: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr@hp.com>

In lure of the sleepable-vs-non-sleepable anon-vma/i_mmap locking
discussion, this patchset encapsulates the i_mmap_mutex lock into
two functions to lock and unlock (for writting). This is very similar
to how we currently deal with anon-vma lock, making it a lot easier to 
change the lock type.

I've split these changes in to two patches since it makes patch 2 nicer
to review, matching additions with deletions. 

Thanks!

Davidlohr Bueso (2):
  mm,fs: introduce helpers around i_mmap_mutex
  fs,mm: use new helper functions around the i_mmap_mutex

 fs/hugetlbfs/inode.c    |  4 ++--
 include/linux/fs.h      | 10 ++++++++++
 kernel/events/uprobes.c |  4 ++--
 kernel/fork.c           |  4 ++--
 mm/filemap_xip.c        |  4 ++--
 mm/fremap.c             |  4 ++--
 mm/hugetlb.c            | 12 ++++++------
 mm/memory-failure.c     |  4 ++--
 mm/memory.c             |  8 ++++----
 mm/mmap.c               | 14 +++++++-------
 mm/mremap.c             |  4 ++--
 mm/nommu.c              | 14 +++++++-------
 mm/rmap.c               | 16 ++++++++--------
 13 files changed, 56 insertions(+), 46 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
