Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4996B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 12:05:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l6so73937697wml.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:05:08 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id kh8si66001690wjb.218.2016.04.18.09.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 09:05:07 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id u206so131487039wme.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:05:07 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH resend 2/3] openrisc: drop wrongly typed definition of page_to_virt()
Date: Mon, 18 Apr 2016 18:04:56 +0200
Message-Id: <1460995497-24312-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, lftan@altera.com, jonas@southpole.se
Cc: will.deacon@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
