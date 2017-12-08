Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 511D06B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 21:56:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p17so7376467pfh.18
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 18:56:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor1142519pls.128.2017.12.07.18.56.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 18:56:30 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 0/9] remove some of unneeded kallsyms includes
Date: Fri,  8 Dec 2017 11:56:07 +0900
Message-Id: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

	A small patch set that removes some kallsyms includes
here and there. Mostly those kallsyms includes are leftovers:
printk() gained %pS/%pF modifiers support some time ago, so
print_symbol() and friends became sort of unneeded [along with
print_fn_descriptor_symbol() deprecation], thus some of the
users were converted to pS/pF. This patch set just cleans up
that convertion.

	We still have a number of print_symbol() users [which
must be converted to ps/pf, print_symbol() uses a stack buffer
KSYM_SYMBOL_LEN to do what printk(ps/pf) can do], but this is
out of scope.

	I compile tested the patch set; but, as always and
usual, would be great if 0day build robot double check it.

Sergey Senozhatsky (9):
  sched/autogroup: remove unneeded kallsyms include
  mm: remove unneeded kallsyms include
  power: remove unneeded kallsyms include
  pci: remove unneeded kallsyms include
  pnp: remove unneeded kallsyms include
  mm: remove unneeded kallsyms include
  workqueue: remove unneeded kallsyms include
  hrtimer: remove unneeded kallsyms include
  genirq: remove unneeded kallsyms include

 drivers/base/power/main.c | 1 -
 drivers/pci/quirks.c      | 1 -
 drivers/pnp/quirks.c      | 1 -
 kernel/irq/spurious.c     | 1 -
 kernel/sched/autogroup.c  | 1 -
 kernel/time/hrtimer.c     | 1 -
 kernel/workqueue.c        | 1 -
 mm/memory.c               | 4 ----
 mm/vmalloc.c              | 1 -
 9 files changed, 12 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
