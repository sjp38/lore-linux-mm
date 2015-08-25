Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7730F82F63
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:57:55 -0400 (EDT)
Received: by iods203 with SMTP id s203so204445700iod.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:57:55 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id ck2si2106321igc.25.2015.08.25.14.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:24 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 5/11] x86/asm: Add pud_pgprot() and pmd_pgprot()
Date: Tue, 25 Aug 2015 15:55:05 -0600
Message-Id: <1440539711-2985-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

pte_pgprot() returns a pgprot_t value by calling pte_flags().  Now
that pud_flags() and pmd_flags() work specifically for the pud/pmd
levels, define pud_pgprot() and pmd_pgprot() for PUD/PMD.

Also update pte_pgprot() to remove the unnecessary mask with
PTE_FLAGS_MASK as pte_flags() takes care of it.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
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
