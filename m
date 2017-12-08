Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E237A6B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 08:43:33 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j4so6010894wrg.15
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 05:43:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z192si1162945wmz.197.2017.12.08.05.43.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 05:43:32 -0800 (PST)
Date: Fri, 8 Dec 2017 14:43:30 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 1/9] sched/autogroup: remove unneeded kallsyms include
Message-ID: <20171208134330.gcimodmkzxfovvm7@pathway.suse.cz>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
 <20171208105611.rcoxze4erxkpimad@hirez.programming.kicks-ass.net>
 <20171208112048.GH628@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208112048.GH628@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 2017-12-08 20:20:48, Sergey Senozhatsky wrote:
> On (12/08/17 11:56), Peter Zijlstra wrote:
> > On Fri, Dec 08, 2017 at 11:56:08AM +0900, Sergey Senozhatsky wrote:
> > > Autogroup does not seem to use any of kallsyms functions/defines.
> > > 
> > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Cc: Peter Zijlstra <peterz@infradead.org>
> > 
> > Feel free to take this through whatever tree you need this in.
> > 
> > Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks!

> Petr, let's pick up sched/autogroup patches then. Thank you.

Yup, I have pushed both patches into printk.git for-4.16:

https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/commit/?h=for-4.16&id=79ee842891595293be37c5aed0e75b4630166c5a
https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/commit/?h=for-4.16&id=25493e5fba2f7b8cdade29d0fc8945114ee7732b

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
