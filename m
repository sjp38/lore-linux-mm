Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 00D6F6B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 08:10:55 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/5] bypass root memcg charges if no memcgs are possible
Date: Tue,  5 Mar 2013 17:10:53 +0400
Message-Id: <1362489058-3455-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org

Hi,

Here is my recent changes in my patchset to bypass charges from the root cgroup
if no other memcgs are present in the system. At the time, the main complaint
came from Michal Hocko, correctly pointing out that if hierarchy == 0, we can't
bypass the root memcg forever and at some point, we need to transfer charges.
This is now done in this patch.

DISCLAIMER:

I haven't yet got access to a big box again. I am sending this with outdated
numbers in the interest of having this in the open earlier. However, the main
idea stands, and I believe the numbers are still generally valid (albeit of
course, it would be better to have them updated. Independent evaluations always
welcome)

* v2
- Fixed some LRU bugs
- Only keep bypassing if we have root-level hierarchy.

Glauber Costa (5):
  memcg: make nocpu_base available for non hotplug
  memcg: provide root figures from system totals
  memcg: make it suck faster
  memcg: do not call page_cgroup_init at system_boot
  memcg: do not walk all the way to the root for memcg

 include/linux/memcontrol.h  |  72 ++++++++++---
 include/linux/page_cgroup.h |  28 ++---
 init/main.c                 |   2 -
 mm/memcontrol.c             | 243 ++++++++++++++++++++++++++++++++++++++++----
 mm/page_cgroup.c            | 150 ++++++++++++++-------------
 5 files changed, 382 insertions(+), 113 deletions(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
