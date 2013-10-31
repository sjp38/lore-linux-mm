Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 363686B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 08:55:14 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so2760355pbb.17
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 05:55:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id gv2si1818475pbb.251.2013.10.31.05.55.12
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 05:55:13 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zwu.kernel@gmail.com>;
	Thu, 31 Oct 2013 08:55:10 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6A84238C803B
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 08:55:07 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9VCt8ZO58327286
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 12:55:08 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9VCt705005676
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 08:55:07 -0400
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/2] mm: fix the comment in zlc_setup()
Date: Thu, 31 Oct 2013 20:52:33 +0800
Message-Id: <1383223953-28803-2-git-send-email-zwu.kernel@gmail.com>
In-Reply-To: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
References: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..3d94d0c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1711,7 +1711,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
  * comments in mmzone.h.  Reduces cache footprint of zonelist scans
  * that have to skip over a lot of full or unallowed zones.
  *
- * If the zonelist cache is present in the passed in zonelist, then
+ * If the zonelist cache is present in the passed zonelist, then
  * returns a pointer to the allowed node mask (either the current
  * tasks mems_allowed, or node_states[N_MEMORY].)
  *
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
