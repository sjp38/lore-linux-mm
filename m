Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3DA946B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:13:23 -0500 (EST)
Message-ID: <5111E612.4010907@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:11:46 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/7] mm: fix types for some functions and variables in case
 of overflow
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Currently, the amount of RAM that functions nr_free_*_pages return
is held in unsigned int. But in machines with big memory (exceeding
16TB), the amount may be incorrect because of overflow, so fix this
problem.

Also, fix the types of variables that is related to nr_free_*_pages.
For these variables are placed in several subsystems, I may be incorrectly
fix them, if there is any problem with the fix, please correct me.

Zhang Yanfei (7):
  mm: fix return type for functions nr_free_*_pages
  ia64: use %ld to print pages calculated in nr_free_buffer_pages
  fs/buffer.c: change type of max_buffer_heads to unsigned long
  fs/nfsd: change type of max_delegations, nfsd_drc_max_mem and
    nfsd_drc_mem_used
  vmscan: change type of vm_total_pages to unsigned long
  net: change type of netns_ipvs->sysctl_sync_qlen_max
  net: change type of virtio_chan->p9_max_pages

 arch/ia64/mm/contig.c    |    2 +-
 arch/ia64/mm/discontig.c |    2 +-
 fs/buffer.c              |    4 ++--
 fs/nfsd/nfs4state.c      |    6 +++---
 fs/nfsd/nfsd.h           |    6 +++---
 fs/nfsd/nfssvc.c         |    6 +++---
 include/linux/swap.h     |    6 +++---
 include/net/ip_vs.h      |    2 +-
 mm/page_alloc.c          |    8 ++++----
 mm/vmscan.c              |    2 +-
 net/9p/trans_virtio.c    |    2 +-
 11 files changed, 23 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
