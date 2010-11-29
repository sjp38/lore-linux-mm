Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D5D48D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:23:41 -0500 (EST)
Received: by pvc30 with SMTP id 30so985402pvc.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 07:23:36 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 0/3] f/madivse(DONTNEED) support
Date: Tue, 30 Nov 2010 00:23:18 +0900
Message-Id: <cover.1291043273.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Recently there is a report about working set page eviction due to rsync
workload. application programmers want to use fadvise but it's not easy.
You could see detailed description on [1/3].

 - [1/3] is to move invalidated page which is dirty/writeback on active list
   into inactive list's head.
 - [2/3] is for moving invalidated page into inactive list's tail when the
   page's writeout is completed.
 - [3/3] is to not calling mark_page_accessed in case of madvise(DONTNEED).

Minchan Kim (3):
  deactivate invalidated pages
  Reclaim invalidated page ASAP
  Prevent activation of page in madvise_dontneed

 include/linux/mm.h   |    4 +-
 include/linux/swap.h |    1 +
 mm/madvise.c         |    4 +-
 mm/memory.c          |   38 +++++++++++-------
 mm/mmap.c            |    4 +-
 mm/page-writeback.c  |   12 +++++-
 mm/swap.c            |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/truncate.c        |   16 ++++++--
 8 files changed, 155 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
