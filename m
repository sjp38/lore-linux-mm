Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id ACFC96B024C
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:33 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so2799845pdj.19
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.166])
        by mx.google.com with SMTP id qj1si8088278pbc.144.2013.11.08.15.43.31
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:32 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 23/24] mm/ARM: mm: Use memblock apis for early memory allocations
Date: Fri, 8 Nov 2013 18:41:59 -0500
Message-ID: <1383954120-24368-24-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 arch/arm/mm/init.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index cef338d..091e2c9 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -414,7 +414,7 @@ free_memmap(unsigned long start_pfn, unsigned long end_pfn)
 	 * free the section of the memmap array.
 	 */
 	if (pg < pgend)
-		free_bootmem(pg, pgend - pg);
+		memblock_free_early(pg, pgend - pg);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
