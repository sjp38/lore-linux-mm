Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 615AD6B004D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 19:15:24 -0500 (EST)
Received: by yenq10 with SMTP id q10so462812yen.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 16:15:23 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: fix a typo in documentation
Date: Fri,  9 Dec 2011 16:15:20 -0800
Message-Id: <1323476120-8964-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

A tiny typo on mapped_file stat.

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 070c016..c0f409e 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -410,7 +410,7 @@ hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
 
 total_cache		- sum of all children's "cache"
 total_rss		- sum of all children's "rss"
-total_mapped_file	- sum of all children's "cache"
+total_mapped_file	- sum of all children's "mapped_file"
 total_mlock		- sum of all children's "mlock"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
