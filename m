Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 847CC6B0081
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:32:18 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1619825pbc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:32:17 -0800 (PST)
Date: Thu, 15 Nov 2012 14:32:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] thp: copy_huge_pmd(): copy huge zero page v6 fix
In-Reply-To: <1353007622-18393-4-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211151431280.27188@chino.kir.corp.google.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com> <1353007622-18393-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

Fix comment

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -791,7 +791,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 	/*
-	 * mm->pagetable lock is enough to be sure that huge zero pmd is not
+	 * mm->page_table_lock is enough to be sure that huge zero pmd is not
 	 * under splitting since we don't split the page itself, only pmd to
 	 * a page table.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
