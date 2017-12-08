Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6AE6B0260
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:57:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a10so6792069pgq.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:57:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z65sor2058773pgb.230.2017.12.07.18.57.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:57:06 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 4/9] pci: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:11 +0900
Message-Id: <20171208025616.16267-5-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The file was converted from print_fn_descriptor_symbol()
to %pF some time ago (c9bbb4abb658da "PCI: use %pF instead
of print_fn_descriptor_symbol() in quirks.c"). kallsyms does
not seem to be needed anymore.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/quirks.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 10684b17d0bd..fd49b976973f 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -19,7 +19,6 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/acpi.h>
-#include <linux/kallsyms.h>
 #include <linux/dmi.h>
 #include <linux/pci-aspm.h>
 #include <linux/ioport.h>
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
