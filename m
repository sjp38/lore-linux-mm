Received: by fg-out-1718.google.com with SMTP id 19so7380489fgg.4
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 10:23:54 -0700 (PDT)
From: Andrea Righi <righi.andrea@gmail.com>
Subject: [PATCH 1/1] x86: remove unused variable pmd warning
Date: Mon, 28 Jul 2008 19:23:52 +0200
Message-Id: <1217265832-19686-1-git-send-email-righi.andrea@gmail.com>
In-Reply-To: <>
References: <>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Righi <righi.andrea@gmail.com>
List-ID: <linux-mm.kvack.org>

Remove the following warning on x86 when CONFIG_X86_PAE is not set:

    arch/x86/mm/pgtable.c: In function a??pgd_mop_up_pmdsa??:
    arch/x86/mm/pgtable.c:194: warning: unused variable a??pmda??

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 include/asm-generic/pgtable-nopmd.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index 087325e..fe9c96b 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -54,7 +54,10 @@ static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
  * inside the pud, so has no extra memory associated with it.
  */
 #define pmd_alloc_one(mm, address)		NULL
-#define pmd_free(mm, x)				do { } while (0)
+struct mm_struct;
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+}
 #define __pmd_free_tlb(tlb, x)			do { } while (0)
 
 #undef  pmd_addr_end
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
