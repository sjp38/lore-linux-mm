Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id DBBC46B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:24:11 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 0/3] cleanup memcg controller initialization
Date: Tue,  5 Feb 2013 17:23:58 +0100
Message-Id: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

Hi,
this is just a small cleanup I promised some time ago[1]. It just moves
all memcg controller initialization code independant on mem_cgroup into
subsystem initialization code.

There are no functional changes.

Diffstat even says that we have saved some lines.
 mm/memcontrol.c |   49 +++++++++++++++++++++----------------------------
 1 file changed, 21 insertions(+), 28 deletions(-)

Shortlog says:
Michal Hocko (3):
      memcg: move mem_cgroup_soft_limit_tree_init to mem_cgroup_init
      memcg: move memcg_stock initialization to mem_cgroup_init
      memcg: cleanup mem_cgroup_init comment
---
[1] https://lkml.org/lkml/2012/12/18/256

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
