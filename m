Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 024EC6B0011
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:11 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:45:10 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C128F38C8021
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:06 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKj6F2273248
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:06 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKioJX025503
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:44:50 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 03/24] XXX: memory_hotplug locking note in online_pages.
Date: Thu, 28 Feb 2013 12:44:11 -0800
Message-Id: <1362084272-11282-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b81a367b..102c06a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -984,6 +984,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	zone->managed_pages += onlined_pages;
 	zone->present_pages += onlined_pages;
+	/* FIXME: should be protected by pgdat_resize_lock() */
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages) {
 		node_states_set_node(zone_to_nid(zone), &arg);
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
