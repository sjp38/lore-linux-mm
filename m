Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 665516B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 16:53:32 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so2017090wib.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:53:31 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id y9si5284951wie.71.2014.10.01.13.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 13:53:31 -0700 (PDT)
Received: by mail-wi0-f170.google.com with SMTP id hi2so1718874wib.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:53:31 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] MM: dmapool: Fixed a brace coding style issue
Date: Wed,  1 Oct 2014 21:53:27 +0100
Message-Id: <1412196807-9990-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sato.vintage@gmail.com, daeseok.youn@gmail.com, andriy.shevchenko@linux.intel.com, jkosina@suse.cz, khalasa@piap.pl, akpm@linux-foundation.org

Removed 3 brace coding style for any arm of this statement

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/dmapool.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index ba8019b..8f4a79a 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -133,28 +133,25 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	struct dma_pool *retval;
 	size_t allocation;
 
-	if (align == 0) {
+	if (align == 0)
 		align = 1;
-	} else if (align & (align - 1)) {
+	else if (align & (align - 1))
 		return NULL;
-	}
 
-	if (size == 0) {
+	if (size == 0)
 		return NULL;
-	} else if (size < 4) {
+	else if (size < 4)
 		size = 4;
-	}
 
 	if ((size % align) != 0)
 		size = ALIGN(size, align);
 
 	allocation = max_t(size_t, size, PAGE_SIZE);
 
-	if (!boundary) {
+	if (!boundary)
 		boundary = allocation;
-	} else if ((boundary < size) || (boundary & (boundary - 1))) {
+	else if ((boundary < size) || (boundary & (boundary - 1)))
 		return NULL;
-	}
 
 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
 	if (!retval)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
