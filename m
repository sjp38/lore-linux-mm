Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 2CA486B0029
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 11:24:50 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 4 Feb 2013 09:24:49 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id ED30C19D8036
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 09:24:45 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r14GOebi454766
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 09:24:40 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r14GNvCM022574
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 09:23:58 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zsmalloc: replace local MAX() with max()
Date: Mon,  4 Feb 2013 10:23:53 -0600
Message-Id: <1359995033-30225-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch removes the local define MAX() macro with the
kernel-wide max() macro from kernel.h

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
Based on greg/staging-next

 drivers/staging/zsmalloc/zsmalloc-main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 06f73a9..fd63b67 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -122,10 +122,9 @@
 #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
 
-#define MAX(a, b) ((a) >= (b) ? (a) : (b))
 /* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
 #define ZS_MIN_ALLOC_SIZE \
-	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
+	max(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
 #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
 /*
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
