Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 741876B0263
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:32 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 127so100549005wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:32 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id ja2si5703451wjb.5.2016.03.30.07.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:31 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id 20so74640939wmh.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:31 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 8/9] openrisc: drop wrongly typed definition of page_to_virt()
Date: Wed, 30 Mar 2016 16:46:03 +0200
Message-Id: <1459349164-27175-9-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

To align with generic code and other architectures that expect the macro
page_to_virt to produce an expression whose type is 'void*', drop the
arch specific definition, which is never referenced anyway.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/openrisc/include/asm/page.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/openrisc/include/asm/page.h b/arch/openrisc/include/asm/page.h
index e613d3673034..35bcb7cd2cde 100644
--- a/arch/openrisc/include/asm/page.h
+++ b/arch/openrisc/include/asm/page.h
@@ -81,8 +81,6 @@ typedef struct page *pgtable_t;
 
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
