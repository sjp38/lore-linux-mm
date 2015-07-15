From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/5] expose mem_cgroup + cleanups
Date: Wed, 15 Jul 2015 13:14:40 +0200
Message-ID: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi,
this is just the cleanup portion of the series posted previously here:
http://marc.info/?l=linux-kernel&m=143635871831843. I am still thinking
about how to move on regarding mm_struct::owner but this is more tricky
than originally anticipated. The cleanup still makes some sense IMO.

I have incorporated review feedback from Vladimir (thanks!) and dropped
http://marc.info/?l=linux-mm&m=143635849631722&w=2 because Vladimir
didn't like it.

Diffstat:
 include/linux/memcontrol.h | 387 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/swap.h       |  10 +-
 include/net/sock.h         |  28 ----
 mm/memcontrol.c            | 378 ++++---------------------------------------
 mm/memory-failure.c        |   2 +-
 mm/slab_common.c           |   2 +-
 mm/vmscan.c                |   2 +-
 7 files changed, 390 insertions(+), 419 deletions(-)

Shortlog:
Michal Hocko (4):
      memcg: export struct mem_cgroup
      memcg: get rid of mem_cgroup_root_css for !CONFIG_MEMCG
      memcg: get rid of extern for functions in memcontrol.h
      memcg, tcp_kmem: check for cg_proto in sock_update_memcg

Tejun Heo (1):
      memcg: restructure mem_cgroup_can_attach()
