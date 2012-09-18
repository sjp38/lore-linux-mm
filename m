Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 123466B00A9
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:15:36 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 00/16] slab accounting for memcg
Date: Tue, 18 Sep 2012 18:11:54 +0400
Message-Id: <1347977530-29755-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

This is a followup to the previous kmem series. I divided them logically
so it gets easier for reviewers. But I believe they are ready to be merged
together (although we can do a two-pass merge if people would prefer)

Throwaway git tree found at:

	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab

There are mostly bugfixes since last submission.

For a detailed explanation about this series, please refer to my previous post
(Subj: [PATCH v3 00/13] kmem controller for memcg.)


Glauber Costa (16):
  slab/slub: struct memcg_params
  slub: use free_page instead of put_page for freeing kmalloc
    allocation
  slab: Ignore the cflgs bit in cache creation
  provide a common place for initcall processing in kmem_cache
  consider a memcg parameter in kmem_create_cache
  memcg: infrastructure to match an allocation to the right cache
  memcg: skip memcg kmem allocations in specified code regions
  slab: allow enable_cpu_cache to use preset values for its tunables
  sl[au]b: always get the cache from its page in kfree
  sl[au]b: Allocate objects from memcg cache
  memcg: destroy memcg caches
  memcg/sl[au]b Track all the memcg children of a kmem_cache.
  slab: slab-specific propagation changes.
  slub: slub-specific propagation changes.
  memcg/sl[au]b: shrink dead caches
  Add documentation about the kmem controller

 Documentation/cgroups/memory.txt |  73 ++++++-
 include/linux/memcontrol.h       |  60 ++++++
 include/linux/sched.h            |   1 +
 include/linux/slab.h             |  23 +++
 include/linux/slab_def.h         |   4 +
 include/linux/slub_def.h         |  18 +-
 init/Kconfig                     |   2 +-
 mm/memcontrol.c                  | 403 +++++++++++++++++++++++++++++++++++++++
 mm/slab.c                        |  70 ++++++-
 mm/slab.h                        |  72 ++++++-
 mm/slab_common.c                 |  85 ++++++++-
 mm/slob.c                        |   5 +
 mm/slub.c                        |  54 ++++--
 13 files changed, 829 insertions(+), 41 deletions(-)

-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
