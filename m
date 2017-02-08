Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF746B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:11:29 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v96so146127185ioi.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:11:29 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id e10si14817760iod.95.2017.02.08.06.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:11:28 -0800 (PST)
Date: Wed, 8 Feb 2017 15:11:26 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208141126.GY6515@twins.programming.kicks-ass.net>
References: <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
 <20170208073527.GA5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081253590.3536@nanos>
 <20170208122612.wasq72hbj4nkh7y3@techsingularity.net>
 <alpine.DEB.2.20.1702081419500.3536@nanos>
 <20170208140332.syic3peyfavd3kl6@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170208140332.syic3peyfavd3kl6@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Feb 08, 2017 at 02:03:32PM +0000, Mel Gorman wrote:
> > Yeah, we'll sort that out once it hits Linus tree and we move RT forward.
> > Though I have once complaint right away:
> > 
> > +	preempt_enable_no_resched();
> > 
> > This is a nono, even in mainline. You effectively disable a preemption
> > point.
> > 
> 
> This came up during review on whether it should or shouldn't be a preemption
> point. Initially it was preempt_enable() but a preemption point didn't
> exist before, the reviewer pushed for it and as it was the allocator fast
> path that was unlikely to need a reschedule or preempt, I made the change.

Not relevant. The only acceptable use of preempt_enable_no_resched() is
if the next statement is a schedule() variant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
