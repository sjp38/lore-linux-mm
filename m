Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9A49E6B0258
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:22 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so20128780obb.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:22 -0700 (PDT)
Received: from g2t4621.austin.hp.com (g2t4621.austin.hp.com. [15.73.212.80])
        by mx.google.com with ESMTPS id f127si2424860oib.58.2015.09.17.11.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 5/11] x86/asm: Add pud_pgprot() and pmd_pgprot()
Date: Thu, 17 Sep 2015 12:24:18 -0600
Message-Id: <1442514264-12475-6-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>

pte_pgprot() returns a pgprot_t value by calling pte_flags().  Now
that pud_flags() and pmd_flags() work specifically for the pud/pmd
levels, define pud_pgprot() and pmd_pgprot() for PUD/PMD.

Also update pte_pgprot() to remove the unnecessary mask with
PTE_FLAGS_MASK as pte_flags() takes care of it.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/include/asm/pgtable.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 714ad06..40a9ffa 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -376,7 +376,9 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 	return __pgprot(preservebits | addbits);
 }
 
-#define pte_pgprot(x) __pgprot(pte_flags(x) & PTE_FLAGS_MASK)
+#define pte_pgprot(x) __pgprot(pte_flags(x))
+#define pmd_pgprot(x) __pgprot(pmd_flags(x))
+#define pud_pgprot(x) __pgprot(pud_flags(x))
 
 #define canon_pgprot(p) __pgprot(massage_pgprot(p))
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
