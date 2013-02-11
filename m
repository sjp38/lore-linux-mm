Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 654496B0007
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 03:04:31 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] fixups for memcg cgroup_lock conversion
Date: Mon, 11 Feb 2013 12:04:47 +0400
Message-Id: <1360569889-843-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

Andrew,

Please consider applying the following fixups to two of the patches
in my latest cgroup_lock conversion series. Apparently, there were
some mistake while converting one of the functions,
mem_cgroup_oom_control_write. Smatch found this one due in kbuild
to the lock imbalance when exiting the function.

Names should be already in your fixup format.

Glauber Costa (2):
  memcg: fast hierarchy-aware child test fix
  memcg: replace cgroup_lock with memcg specific memcg_lock fix

 mm/memcontrol.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
