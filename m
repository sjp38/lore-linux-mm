Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C7B486B009A
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:31 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 17:13:31 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E6BFE3E40044
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:11 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DNDRgR128796
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:27 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DNDQm7023246
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:26 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 1/4] mm: fix comment referring to non-existent size_seqlock, change to span_seqlock
Date: Mon, 13 May 2013 16:13:04 -0700
Message-Id: <1368486787-9511-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5c76737..fc859a0c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -716,7 +716,7 @@ typedef struct pglist_data {
 	 * or node_spanned_pages stay constant.  Holding this will also
 	 * guarantee that any pfn_valid() stays that way.
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
