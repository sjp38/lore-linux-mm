Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 65B9E6B009D
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:35 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 19:13:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E0ECE6E8028
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:26 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DNDTnU263482
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:30 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DNDSfk023361
	for <linux-mm@kvack.org>; Mon, 13 May 2013 17:13:29 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 2/4] mmzone: note that node_size_lock should be manipulated via pgdat_resize_lock()
Date: Mon, 13 May 2013 16:13:05 -0700
Message-Id: <1368486787-9511-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc859a0c..41557be 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -716,6 +716,9 @@ typedef struct pglist_data {
 	 * or node_spanned_pages stay constant.  Holding this will also
 	 * guarantee that any pfn_valid() stays that way.
 	 *
+	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
+	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG.
+	 *
 	 * Nests above zone->lock and zone->span_seqlock
 	 */
 	spinlock_t node_size_lock;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
