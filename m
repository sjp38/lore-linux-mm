Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 0FADA6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 19:32:11 -0500 (EST)
Date: Sun, 18 Dec 2011 01:32:09 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Use 'do {} while (0)' for empty flush_tlb_fix_spurious_fault()
 macro
Message-ID: <alpine.LNX.2.00.1112180128070.21784@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-693025022-1324168117=:21784"
Content-ID: <alpine.LNX.2.00.1112180128450.21784@swampdragon.chaosbits.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-693025022-1324168117=:21784
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-7
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LNX.2.00.1112180128451.21784@swampdragon.chaosbits.net>

If one builds the kernel with -Wempty-body one gets this warning:

  mm/memory.c:3432:46: warning: suggest braces around empty body in an !ifc statement [-Wempty-body]

due to the fact that 'flush_tlb_fix_spurious_fault' is a macro that
can sometimes be defined to nothing.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 arch/x86/include/asm/pgtable.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 18601c8..ebe7e76 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -703,7 +703,7 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
 	pte_update(mm, addr, ptep);
 }
 
-#define flush_tlb_fix_spurious_fault(vma, address)
+#define flush_tlb_fix_spurious_fault(vma, address) do {} while (0)
 
 #define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
 
-- 
1.7.8


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
--8323328-693025022-1324168117=:21784--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
