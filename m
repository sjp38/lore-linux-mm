Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC92D6B0269
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 18:51:19 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y205so303217848qkb.4
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:19 -0800 (PST)
Received: from mail-qt0-f174.google.com (mail-qt0-f174.google.com. [209.85.216.174])
        by mx.google.com with ESMTPS id t1si12950251qkh.335.2016.12.06.15.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 15:51:19 -0800 (PST)
Received: by mail-qt0-f174.google.com with SMTP id n6so363250688qtd.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:19 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv5 05/11] mm: Introduce lm_alias
Date: Tue,  6 Dec 2016 15:50:51 -0800
Message-Id: <1481068257-6367-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1481068257-6367-1-git-send-email-labbott@redhat.com>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


Certain architectures may have the kernel image mapped separately to
alias the linear map. Introduce a macro lm_alias to translate a kernel
image symbol into its linear alias. This is used in part with work to
add CONFIG_DEBUG_VIRTUAL support for arm64.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v5: Split off from the arm64 conversion to __pa_symbol
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..88556b8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -76,6 +76,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define page_to_virt(x)	__va(PFN_PHYS(page_to_pfn(x)))
 #endif
 
+#ifndef lm_alias
+#define lm_alias(x)	__va(__pa_symbol(x))
+#endif
+
 /*
  * To prevent common memory management code establishing
  * a zero page mapping on a read fault.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
