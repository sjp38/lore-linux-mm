Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 154806B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:48:51 -0500 (EST)
Received: by ggnq2 with SMTP id q2so771923ggn.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:48:49 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: fix the document of pgpgin/pgpgout
Date: Mon, 21 Nov 2011 16:48:45 -0800
Message-Id: <1321922925-14930-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

The two memcg stats pgpgin/pgpgout have different meaning than the ones in
vmstat, which indicates that we picked a bad naming for them. It might be late
to change the stat name, but better documentation is always helpful.

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index cc0ebc5..eb6a911 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -386,8 +386,11 @@ memory.stat file includes following statistics
 cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
 mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
-pgpgin		- # of pages paged in (equivalent to # of charging events).
-pgpgout		- # of pages paged out (equivalent to # of uncharging events).
+pgpgin		- # of charging events to the memory cgroup. The charging
+		event happens each time a page is accounted as either mapped
+		anon page(RSS) or cache page(Page Cache) to the cgroup.
+pgpgout		- # of uncharging events to the memory cgroup. The uncharging
+		event happens each time a page is unaccounted from the cgroup.
 swap		- # of bytes of swap usage
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
