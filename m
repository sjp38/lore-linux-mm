Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E44566B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:52:40 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id uo1so9910526pbc.17
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:52:40 -0700 (PDT)
From: SeungHun Lee <waydi1@gmail.com>
Subject: [PATCH] mm: page_alloc: fix comment get_page_from_freelist
Date: Thu, 25 Jul 2013 00:52:01 +0900
Message-Id: <1374681121-1340-1-git-send-email-waydi1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: SeungHun Lee <waydi1@gmail.com>

cpuset_zone_allowed is changed to cpuset_zone_allowed_softwall

and the comment is moved to __cpuset_node_allowed_softwall.

So fix this comment.

Signed-off-by: SeungHun Lee <waydi1@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..b8475ed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1860,7 +1860,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
-	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
