Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7D626B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:20:54 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so8552432pfh.16
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:20:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v32sor2915901plb.104.2017.12.08.03.20.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 03:20:53 -0800 (PST)
Date: Fri, 8 Dec 2017 20:20:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/9] sched/autogroup: remove unneeded kallsyms include
Message-ID: <20171208112048.GH628@jagdpanzerIV>
References: <20171208025616.16267-1-sergey.senozhatsky@gmail.com>
 <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
 <20171208105611.rcoxze4erxkpimad@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208105611.rcoxze4erxkpimad@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (12/08/17 11:56), Peter Zijlstra wrote:
> On Fri, Dec 08, 2017 at 11:56:08AM +0900, Sergey Senozhatsky wrote:
> > Autogroup does not seem to use any of kallsyms functions/defines.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> 
> Feel free to take this through whatever tree you need this in.
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks!


Petr, let's pick up sched/autogroup patches then. Thank you.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
