Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 817336B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 19:24:20 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so188255pab.29
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:24:20 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ef1si819050pbc.85.2014.05.06.16.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 16:24:19 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so186271pad.23
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:24:19 -0700 (PDT)
From: Marc Carino <marc.ceeeee@gmail.com>
Subject: [PATCH] cma: increase CMA_ALIGNMENT upper limit to 12
Date: Tue,  6 May 2014 16:23:56 -0700
Message-Id: <1399418636-31114-2-git-send-email-marc.ceeeee@gmail.com>
In-Reply-To: <1399418636-31114-1-git-send-email-marc.ceeeee@gmail.com>
References: <1399418636-31114-1-git-send-email-marc.ceeeee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Marc Carino <marc.ceeeee@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org

Some systems require a larger maximum PAGE_SIZE order for CMA
allocations. To accommodate such systems, increase the upper-bound of
the CMA_ALIGNMENT range to 12 (which ends up being 16MB on systems
with 4K pages).

Signed-off-by: Marc Carino <marc.ceeeee@gmail.com>
---
 drivers/base/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 8fa8dea..0fb820c 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -253,7 +253,7 @@ endchoice
 
 config CMA_ALIGNMENT
 	int "Maximum PAGE_SIZE order of alignment for contiguous buffers"
-	range 4 9
+	range 4 12
 	default 8
 	help
 	  DMA mapping framework by default aligns all buffers to the smallest
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
