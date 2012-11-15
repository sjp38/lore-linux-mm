Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6DCA76B0098
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:55:00 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/7] fixups for kmemcg
Date: Thu, 15 Nov 2012 06:54:46 +0400
Message-Id: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

Andrew,

As you requested, here are some fixups and clarifications for the kmemcg series.
It also handles one bug reported by Sasha.

Please note that I didn't touch kmem_cache_shrink(): I believe that deserves a
deeper and more thoughtful solution that will take time to brew. I plan to
address that eventually in the scope of per-memcg kernel memory reclaim.
I did, however, remove the delayed_work in favor of a normal worker. Memory
will stay around for longer, but it will be reclaimed eventually, and given
your objections I believe this is a more desirable trade off.

Please let me know if there is anything you would like to see different, and
sorry for not handling this earlier.

Glauber Costa (7):
  memcg: simplify ida initialization
  move include of workqueue.h to top of slab.h file
  memcg: remove test for current->mm in memcg_stop/resume_kmem_account
  memcg: replace __always_inline with plain inline
  memcg: get rid of once-per-second cache shrinking for dead memcgs
  memcg: add comments clarifying aspects of cache attribute propagation
  slub: drop mutex before deleting sysfs entry

 include/linux/memcontrol.h | 12 +++++++++---
 include/linux/slab.h       |  6 +++---
 mm/memcontrol.c            | 34 ++++++++++------------------------
 mm/slab.c                  |  1 +
 mm/slub.c                  | 34 +++++++++++++++++++++++++++++-----
 5 files changed, 52 insertions(+), 35 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
