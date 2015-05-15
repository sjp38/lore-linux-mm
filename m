Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 309B86B0071
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:23 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so13568192pad.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:22 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id tg11si2759908pac.21.2015.05.15.06.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:20 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE0095H9ISOX80@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:16 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 2/5] x86: kasan: fix types in kasan page tables declarations
Date: Fri, 15 May 2015 16:59:01 +0300
Message-id: <1431698344-28054-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/include/asm/kasan.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index 8b22422..b766c55 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -15,8 +15,8 @@
 #ifndef __ASSEMBLY__
 
 extern pte_t kasan_zero_pte[];
-extern pte_t kasan_zero_pmd[];
-extern pte_t kasan_zero_pud[];
+extern pmd_t kasan_zero_pmd[];
+extern pud_t kasan_zero_pud[];
 
 #ifdef CONFIG_KASAN
 void __init kasan_map_early_shadow(pgd_t *pgd);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
