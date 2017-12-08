Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4DE6B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:56:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so6779879pgv.5
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:56:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15sor1893702pge.400.2017.12.07.18.56.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:56:39 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 1/9] sched/autogroup: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:08 +0900
Message-Id: <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Autogroup does not seem to use any of kallsyms functions/defines.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 kernel/sched/autogroup.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/sched/autogroup.c b/kernel/sched/autogroup.c
index a43df5193538..0786227a3f48 100644
--- a/kernel/sched/autogroup.c
+++ b/kernel/sched/autogroup.c
@@ -3,7 +3,6 @@
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#include <linux/kallsyms.h>
 #include <linux/utsname.h>
 #include <linux/security.h>
 #include <linux/export.h>
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
