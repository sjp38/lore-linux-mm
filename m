Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C17A6B026F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 18:55:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a74so2388672pfg.20
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 15:55:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor2365308pgb.265.2017.12.08.15.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 15:55:53 -0800 (PST)
Date: Sat, 9 Dec 2017 08:55:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 4/9] pci: remove unneeded kallsyms include
Message-ID: <20171208235549.GD489@tigerII.localdomain>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <20171208025616.16267-5-sergey.senozhatsky@gmail.com>
 <20171208175345.GA12367@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208175345.GA12367@bhelgaas-glaptop.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (12/08/17 11:53), Bjorn Helgaas wrote:
> On Fri, Dec 08, 2017 at 11:56:11AM +0900, Sergey Senozhatsky wrote:
> > The file was converted from print_fn_descriptor_symbol()
> > to %pF some time ago (c9bbb4abb658da "PCI: use %pF instead
> > of print_fn_descriptor_symbol() in quirks.c"). kallsyms does
> > not seem to be needed anymore.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Bjorn Helgaas <bhelgaas@google.com>
> 
> Applied to pci/misc for v4.16, thanks for cleaning this up!

thanks!

> I *assume* there's no ordering dependency like the one you mentioned
> for sched/printk.

no dependency. you are right.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
