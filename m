Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id E759028029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:25:02 -0400 (EDT)
Received: by oibn4 with SMTP id n4so32140270oib.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:25:02 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id o7si4193787obp.14.2015.07.15.09.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:25:02 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 2/4] x86, asm: Move PUD_PAGE macros to page_types.h
Date: Wed, 15 Jul 2015 10:23:53 -0600
Message-Id: <1436977435-31826-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
References: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

PUD_SHIFT is defined according to a kernel configuration, which
allows it be commonly used by any kernels.  However, PUD_PAGE_SIZE
and PUD_PAGE_MASK, which are calculated from PUD_SHIFT, are defined
in page_64_types.h, which allows them be used by a 64-bit kernel
only.

Move PUD_PAGE_SIZE and PUD_PAGE_MASK to page_types.h so that they
can be used by any kernels as well.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/include/asm/page_64_types.h |    3 ---
 arch/x86/include/asm/page_types.h    |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 4edd53b..4928cf0 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -26,9 +26,6 @@
 #define MCE_STACK 4
 #define N_EXCEPTION_STACKS 4  /* hw limit: 7 */
 
-#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
-#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
-
 /*
  * Set __PAGE_OFFSET to the most negative possible address +
  * PGDIR_SIZE*16 (pgd slot 272).  The gap is to allow a space for a
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index c7c712f..c5b7fb2 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -20,6 +20,9 @@
 #define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
 #define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
 
+#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
+#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
