Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD2F06B0261
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:57:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a13so6796410pgt.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:57:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9sor2345150plt.108.2017.12.07.18.57.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:57:15 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 5/9] pnp: remove unneeded kallsyms include
Date: Fri,  8 Dec 2017 11:56:12 +0900
Message-Id: <20171208025616.16267-6-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The file was converted from print_fn_descriptor_symbol()
to %pF some time ago (2e532d68a2b3e2aa {pci,pnp} quirks.c:
don't use deprecated print_fn_descriptor_symbol()). kallsyms
does not seem to be needed anymore.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pnp/quirks.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/pnp/quirks.c b/drivers/pnp/quirks.c
index f054cdddfef8..803666ae3635 100644
--- a/drivers/pnp/quirks.c
+++ b/drivers/pnp/quirks.c
@@ -21,7 +21,6 @@
 #include <linux/slab.h>
 #include <linux/pnp.h>
 #include <linux/io.h>
-#include <linux/kallsyms.h>
 #include "base.h"
 
 static void quirk_awe32_add_ports(struct pnp_dev *dev,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
