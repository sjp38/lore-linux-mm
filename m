Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44D3D6B0266
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:57:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w1so6766484pgq.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:57:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7sor2042242pgq.135.2017.12.07.18.57.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:57:25 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 6/9] mm: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:13 +0900
Message-Id: <20171208025616.16267-7-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The file was converted from sprint_symbol() to %pS some time
ago (62c70bce8ac23651 "mm: convert sprintf_symbol to %pS").
kallsyms does not seem to be needed anymore.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmalloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..fdda6534e9a0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -19,7 +19,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/debugobjects.h>
-#include <linux/kallsyms.h>
 #include <linux/list.h>
 #include <linux/notifier.h>
 #include <linux/rbtree.h>
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
