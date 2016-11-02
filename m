Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8987B6B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 17:01:08 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l20so11888760qta.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:01:08 -0700 (PDT)
Received: from mail-qt0-f176.google.com (mail-qt0-f176.google.com. [209.85.216.176])
        by mx.google.com with ESMTPS id w7si2177148qkc.77.2016.11.02.14.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 14:01:08 -0700 (PDT)
Received: by mail-qt0-f176.google.com with SMTP id c47so16711127qtc.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:01:07 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv2 4/6] arm64: Add cast for virt_to_pfn
Date: Wed,  2 Nov 2016 15:00:52 -0600
Message-Id: <20161102210054.16621-5-labbott@redhat.com>
In-Reply-To: <20161102210054.16621-1-labbott@redhat.com>
References: <20161102210054.16621-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


virt_to_pfn lacks a cast at the top level. Don't rely on __virt_to_phys
and explicitly cast to unsigned long.

Signed-off-by: Laura Abbott <labbott@redhat.com>
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
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
