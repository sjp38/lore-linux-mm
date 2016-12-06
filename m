Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A39886B0268
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 18:51:16 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id g193so303043207qke.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:16 -0800 (PST)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com. [209.85.216.169])
        by mx.google.com with ESMTPS id s7si12967219qta.337.2016.12.06.15.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 15:51:16 -0800 (PST)
Received: by mail-qt0-f169.google.com with SMTP id c47so362890236qtc.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:16 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv5 04/11] arm64: Add cast for virt_to_pfn
Date: Tue,  6 Dec 2016 15:50:50 -0800
Message-Id: <1481068257-6367-5-git-send-email-labbott@redhat.com>
In-Reply-To: <1481068257-6367-1-git-send-email-labbott@redhat.com>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

virt_to_pfn lacks a cast at the top level. Don't rely on __virt_to_phys
and explicitly cast to unsigned long.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v5: No changes
---
 arch/arm64/include/asm/memory.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index b4d2b32..d773e2c 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -204,7 +204,7 @@ static inline void *phys_to_virt(phys_addr_t x)
 #define __pa(x)			__virt_to_phys((unsigned long)(x))
 #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
-#define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys(x))
+#define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
 
 /*
  *  virt_to_page(k)	convert a _valid_ virtual address to struct page *
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
