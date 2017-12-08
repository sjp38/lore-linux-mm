Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB25E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:56:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so6786231pgf.13
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:56:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12sor2765234pls.2.2017.12.07.18.56.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:56:48 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 2/9] mm: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:09 +0900
Message-Id: <20171208025616.16267-3-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The file was converted from print_symbol() to %pSR a while
ago (071361d3473ebb814 "mm: Convert print_symbol to %pSR").
kallsyms does not seem to be needed anymore.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/memory.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 24e9e1d5488f..551b323c9ab6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,7 +59,6 @@
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
-#include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
@@ -760,9 +759,6 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		dump_page(page, "bad pte");
 	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
 		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
-	/*
-	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
-	 */
 	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
 		 vma->vm_file,
 		 vma->vm_ops ? vma->vm_ops->fault : NULL,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
