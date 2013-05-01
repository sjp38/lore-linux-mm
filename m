Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 422496B01AA
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:37 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:17:36 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DF10D3E4003F
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:17:18 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MHWxp105876
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:17:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MHW2D006857
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:17:32 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 3/4] mmzone: note that node_size_lock should be manipulated via pgdat_resize_lock()
Date: Wed,  1 May 2013 15:17:14 -0700
Message-Id: <1367446635-12856-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index afd0aa5..45be383 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -716,6 +716,8 @@ typedef struct pglist_data {
 	 * or node_spanned_pages stay constant.  Holding this will also
 	 * guarantee that any pfn_valid() stays that way.
 	 *
+	 * Use pgdat_resize_lock() and pgdat_resize_unlock() to manipulate.
+	 *
 	 * Updaters of any of these fields also must hold
 	 * lock_memory_hotplug().
 	 *
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
