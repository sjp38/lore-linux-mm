Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id B09A66B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:15 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 15:16:14 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7E123C90068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:10 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62LGANl371586
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 17:16:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q632l300031635
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:47:03 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
Date: Mon,  2 Jul 2012 16:15:51 -0500
Message-Id: <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Add information on the usage limits of zs_map_object()

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 4942d41..abf7c13 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -747,7 +747,12 @@ EXPORT_SYMBOL_GPL(zs_free);
  *
  * Before using an object allocated from zs_malloc, it must be mapped using
  * this function. When done with the object, it must be unmapped using
- * zs_unmap_object
+ * zs_unmap_object.
+ *
+ * Only one object can be mapped per cpu at a time. There is no protection
+ * against nested mappings.
+ *
+ * This function returns with preemption and page faults disabled.
 */
 void *zs_map_object(struct zs_pool *pool, unsigned long handle)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
