Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1C95E6B01A5
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:32 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 18:17:31 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8BF9F38C801A
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:28 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MHSsC327820
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MHSEI008972
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:28 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 2/4] mm: fix comment referring to non-existent size_seqlock, change to span_seqlock
Date: Wed,  1 May 2013 15:17:13 -0700
Message-Id: <1367446635-12856-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 09ac172..afd0aa5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -719,7 +719,7 @@ typedef struct pglist_data {
 	 * Updaters of any of these fields also must hold
 	 * lock_memory_hotplug().
 	 *
-	 * Nests above zone->lock and zone->size_seqlock.
+	 * Nests above zone->lock and zone->span_seqlock
 	 */
 	spinlock_t node_size_lock;
 #endif
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
