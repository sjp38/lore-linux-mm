Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C63FA9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 10:04:44 -0400 (EDT)
From: Wizard <wizarddewhite@gmail.com>
Subject: [PATCH]   fix find_next_system_ram comments
Date: Tue, 27 Sep 2011 22:02:04 +0800
Message-Id: <1317132124-2820-1-git-send-email-wizarddewhite@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, rdunlap@xenotime.net
Cc: linux-mm@kvack.org, Wizard <wizarddewhite@gmail.com>

The purpose of find_next_system_ram() is to find a the lowest
memory resource which contain or overlap the [res->start, res->end),
not just contain.

In this patch, I make this comment more exact and fix one typo.

Signed-off-by: Wei Yang <wizarddewhite@gmail.com>
---
 kernel/resource.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 3b3cedc..8461aea 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -279,7 +279,8 @@ EXPORT_SYMBOL(release_resource);
 
 #if !defined(CONFIG_ARCH_HAS_WALK_MEMORY)
 /*
- * Finds the lowest memory reosurce exists within [res->start.res->end)
+ * Finds the lowest memory resource which contains or overlaps
+ * [res->start, res->end)
  * the caller must specify res->start, res->end, res->flags and "name".
  * If found, returns 0, res is overwritten, if not found, returns -1.
  */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
