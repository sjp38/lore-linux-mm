Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 61FE06B0074
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 05:30:13 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] Show information about dangling memcgs
Date: Thu, 22 Nov 2012 14:29:48 +0400
Message-Id: <1353580190-14721-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

Hi,

As suggested by Kame, this is a proposed interface to show information
about who and what is keeping memcgs in memory after they are removed.

It is not very complicated, and I was took care to note in the Docs that this
is debug only.

Please let me know if you think.

Glauber Costa (2):
  cgroup: helper do determine group name
  memcg: debugging facility to access dangling memcgs.

 Documentation/cgroups/memory.txt |  13 +++
 include/linux/cgroup.h           |   1 +
 kernel/cgroup.c                  |   9 +++
 mm/memcontrol.c                  | 167 +++++++++++++++++++++++++++++++++++----
 4 files changed, 176 insertions(+), 14 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
