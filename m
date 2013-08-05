Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 81DEC6B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:31:16 -0400 (EDT)
Message-ID: <51FF62C4.9010001@huawei.com>
Date: Mon, 5 Aug 2013 16:31:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] cma: use macro PFN_DOWN when converting size to pages
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Use "PFN_DOWN(r->size)" instead of "r->size >> PAGE_SHIFT".

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/base/dma-contiguous.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 0ca5442..1bcfaed 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -201,13 +201,12 @@ static int __init cma_init_reserved_areas(void)
 {
 	struct cma_reserved *r = cma_reserved;
 	unsigned i = cma_reserved_count;
+	struct cma *cma;
 
 	pr_debug("%s()\n", __func__);
 
 	for (; i; --i, ++r) {
-		struct cma *cma;
-		cma = cma_create_area(PFN_DOWN(r->start),
-				      r->size >> PAGE_SHIFT);
+		cma = cma_create_area(PFN_DOWN(r->start), PFN_DOWN(r->size));
 		if (!IS_ERR(cma))
 			dev_set_cma_area(r->dev, cma);
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
