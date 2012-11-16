Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 20FCB6B0089
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:25:54 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so432634eaa.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:25:53 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 09/19] sched, numa, mm, MIPS/thp: Add pmd_pgprot() implementation
Date: Fri, 16 Nov 2012 17:25:11 +0100
Message-Id: <1353083121-4560-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1353083121-4560-1-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>, Ralf Baechle <ralf@linux-mips.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>

From: Ralf Baechle <ralf@linux-mips.org>

Add the pmd_pgprot() method that will be needed
by the new NUMA code.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/mips/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index c02158b..bbe4cda 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -89,6 +89,8 @@ static inline int is_zero_pfn(unsigned long pfn)
 
 extern void paging_init(void);
 
+#define pmd_pgprot(x)		__pgprot(pmd_val(x) & ~_PAGE_CHG_MASK)
+
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
