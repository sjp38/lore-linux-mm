Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C21F86B0069
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:39:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h18so8510392pfi.2
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:39:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor2928456pll.5.2017.12.08.02.39.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 02:39:36 -0800 (PST)
Date: Fri, 8 Dec 2017 19:39:31 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] sched/autogroup: move sched.h include
Message-ID: <20171208103931.GG628@jagdpanzerIV>
References: <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
 <20171208082422.5021-1-sergey.senozhatsky@gmail.com>
 <20171208085755.GA3148@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208085755.GA3148@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi,

On (12/08/17 09:57), Petr Mladek wrote:
> On Fri 2017-12-08 17:24:22, Sergey Senozhatsky wrote:
> > Move local "sched.h" include to the bottom. sched.h defines
> > several macros that are getting redefined in ARCH-specific
> > code, for instance, finish_arch_post_lock_switch() and
> > prepare_arch_switch(), so we need ARCH-specific definitions
> > to come in first.
> 
> This patch is needed to fix compilation error [1] caused by a patchset
> that deprecates %pf/%pF printk modifiers[2].
> 
> IMHO, we should make sure that this fix goes into Linus' tree
> before the printk-related patchset. What is the best practice,
> please?

as long as sched pull request goes before printk pull request we
are fine. but I see your point.

> I see two reasonable possibilities. Either sched people could
> push this for-4.15-rcX. Or I could put it into printk.git for-4.16
> in the right order.

agreed.

> What do you think?

either way is fine with me. we can have it in print.git (no objections
from my side) or in sched tree and just make sure that sched pull request
has "bigger priority", or it can go to Linus's tree as a potential fix
(I'd prefer the last option, I think).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
