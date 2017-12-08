Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A793C6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:56:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so6773316pgv.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:56:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor1253657plw.53.2017.12.07.18.56.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:56:57 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 3/9] power: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:10 +0900
Message-Id: <20171208025616.16267-4-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The file was converted from print_fn_descriptor_symbol()
to %pF some time ago (c80cfb0406c01bb "vsprintf: use new
vsprintf symbolic function pointer format"). kallsyms does
not seem to be needed anymore.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Rafael Wysocki <rjw@rjwysocki.net>
Cc: Len Brown <len.brown@intel.com>
---
 drivers/base/power/main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
index 5bc2cf1f812c..e2539d8423f7 100644
--- a/drivers/base/power/main.c
+++ b/drivers/base/power/main.c
@@ -18,7 +18,6 @@
  */
 
 #include <linux/device.h>
-#include <linux/kallsyms.h>
 #include <linux/export.h>
 #include <linux/mutex.h>
 #include <linux/pm.h>
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
