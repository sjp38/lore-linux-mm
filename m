Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E07F6B0269
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:43 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so40035308wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:43 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id gz10si32501550wjc.107.2016.02.29.06.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:42 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id n186so52755014wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:42 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 8/9] openrisc: drop wrongly typed definition of page_to_virt()
Date: Mon, 29 Feb 2016 15:44:43 +0100
Message-Id: <1456757084-1078-9-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

To align with generic code and other architectures that expect the macro
page_to_virt to produce an expression whose type is 'void*', drop the
arch specific definition, which is never referenced anyway.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: linux@lists.openrisc.net
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/openrisc/include/asm/page.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/openrisc/include/asm/page.h b/arch/openrisc/include/asm/page.h
index 108906f991d6..1976f7272b1f 100644
--- a/arch/openrisc/include/asm/page.h
+++ b/arch/openrisc/include/asm/page.h
@@ -84,8 +84,6 @@ typedef struct page *pgtable_t;
 
 #define virt_to_page(addr) \
 	(mem_map + (((unsigned long)(addr)-PAGE_OFFSET) >> PAGE_SHIFT))
-#define page_to_virt(page) \
-	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
 #define page_to_phys(page)      ((dma_addr_t)page_to_pfn(page) << PAGE_SHIFT)
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
