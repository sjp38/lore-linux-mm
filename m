Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id F0ADA6B007D
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:55 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id w7so1540964qcr.39
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:55 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id y5si1636460qat.121.2013.12.02.18.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:54 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 07/23] mm/memblock: drop WARN and use SMP_CACHE_BYTES as a default alignment
Date: Mon, 2 Dec 2013 21:27:22 -0500
Message-ID: <1386037658-3161-8-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>

drop WARN and use SMP_CACHE_BYTES as a default alignment in
memblock_alloc_base_nid() as recommended by Tejun Heo in
https://lkml.org/lkml/2013/10/13/117.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 mm/memblock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 53da534..1d15e07 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -883,8 +883,8 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
 {
 	phys_addr_t found;
 
-	if (WARN_ON(!align))
-		align = __alignof__(long long);
+	if (!align)
+		align = SMP_CACHE_BYTES;
 
 	/* align @size to avoid excessive fragmentation on reserved array */
 	size = round_up(size, align);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
