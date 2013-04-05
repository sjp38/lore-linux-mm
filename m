Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2DA816B008A
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 06:00:46 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] page_cgroup cleanups
Date: Fri,  5 Apr 2013 14:01:10 +0400
Message-Id: <1365156072-24100-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hi,

Last time I sent the mem cgroup bypass patches, Kame and Michal pointed out
that some of it was a bit of cleanup, specifically at the page_cgroup side.
I've decided to separate those patches and send them separately. After these
patches are applied, page_cgroup will be initialized together with the root
cgroup, instead of init/main.c

When we move cgroup initialization to the first non-root cgroup created, all
we'll have to do from the page_cgroup side would be to move the initialization
that now happens at root, to the first child.

Glauber Costa (2):
  memcg: consistently use vmalloc for page_cgroup allocations
  memcg: defer page_cgroup initialization

 include/linux/page_cgroup.h | 21 +------------------
 init/main.c                 |  2 --
 mm/memcontrol.c             |  2 ++
 mm/page_cgroup.c            | 51 +++++++++++++++------------------------------
 4 files changed, 20 insertions(+), 56 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
