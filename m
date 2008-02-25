Date: Mon, 25 Feb 2008 23:34:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 00/15] memcg: fixes and cleanups
Message-ID: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's my series of fifteen mem_cgroup patches against 2.6.25-rc3:
fixes to bugs I've found and cleanups made on the way to those fixes.
I believe we'll want these in 2.6.25-rc4.  Mostly they're what was
included in the rollup I posted on Friday, but 05/15 and 15/15 fix
(pre-existing) page migration and force_empty bugs I found after that.
I'm not at all happy with force_empty, 15/15 discusses it a little.

 include/linux/memcontrol.h |   37 +--
 mm/memcontrol.c            |  365 +++++++++++++----------------------
 mm/memory.c                |   13 -
 mm/migrate.c               |   19 +
 mm/page_alloc.c            |   18 +
 mm/rmap.c                  |    4 
 mm/shmem.c                 |    9 
 mm/swap.c                  |    2 
 mm/vmscan.c                |    5 
 9 files changed, 196 insertions(+), 276 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
