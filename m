Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 10BFB6B0297
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:50 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:50 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 38372C9001A
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:46 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301kZu283074
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301jxr013126
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:46 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 30/31] mm/page_alloc: use manage_pages instead of present pages when calculating default_zonelist_order()
Date: Thu,  2 May 2013 17:01:02 -0700
Message-Id: <1367539263-19999-31-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4fe35b24..cc7b332 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3514,8 +3514,8 @@ static int default_zonelist_order(void)
 			z = &NODE_DATA(nid)->node_zones[zone_type];
 			if (populated_zone(z)) {
 				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
+					low_kmem_size += z->managed_pages;
+				total_size += z->managed_pages;
 			} else if (zone_type == ZONE_NORMAL) {
 				/*
 				 * If any node has only lowmem, then node order
@@ -3545,8 +3545,8 @@ static int default_zonelist_order(void)
 			z = &NODE_DATA(nid)->node_zones[zone_type];
 			if (populated_zone(z)) {
 				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
+					low_kmem_size += z->managed_pages;
+				total_size += z->managed_pages;
 			}
 		}
 		if (low_kmem_size &&
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
