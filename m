Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id A4B396B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 18:29:01 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so5347729qaq.19
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:29:01 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id r10si3418059qai.85.2013.11.23.15.29.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 15:29:00 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH] mm: nobootmem: avoid type warning about alignment value
Date: Sat, 23 Nov 2013 18:28:46 -0500
Message-ID: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Building ARM with NO_BOOTMEM generates below warning. Using min_t
to find the correct alignment avoids the warning.

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/nobootmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 2c254d3..8954e43 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -85,7 +85,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
 	int order;
 
 	while (start < end) {
-		order = min(MAX_ORDER - 1UL, __ffs(start));
+		order = min_t(size_t, MAX_ORDER - 1UL, __ffs(start));
 
 		while (start + (1UL << order) > end)
 			order--;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
