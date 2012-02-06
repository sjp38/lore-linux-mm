Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6CD686B13F2
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 15:19:32 -0500 (EST)
Received: by eaai10 with SMTP id i10so45671eaa.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 12:19:30 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: fix up documentation on global LRU.
Date: Mon,  6 Feb 2012 12:19:29 -0800
Message-Id: <1328559569-10783-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

In v3.3-rc1, the global LRU has been removed with commit
"mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.

I left the swap session to someone who has better understanding of
'memory+swap'.

Signed-off-by: Ying Han <yinghan@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memory.txt |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 4c95c00..9b1067a 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -34,8 +34,7 @@ Current Status: linux-2.6.34-mmotm(development version of 2010/April)
 
 Features:
  - accounting anonymous pages, file caches, swap caches usage and limiting them.
- - private LRU and reclaim routine. (system's global LRU and private LRU
-   work independently from each other)
+ - pages are linked to per-memcg LRU exclusively, and there is no global LRU.
  - optionally, memory+swap usage can be accounted and limited.
  - hierarchical accounting
  - soft limit
@@ -154,7 +153,7 @@ updated. page_cgroup has its own LRU on cgroup.
 2.2.1 Accounting details
 
 All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
-Some pages which are never reclaimable and will not be on the global LRU
+Some pages which are never reclaimable and will not be on the LRU
 are not accounted. We just account pages under usual VM management.
 
 RSS pages are accounted at page_fault unless they've already been accounted
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
