Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8C26C6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:48:31 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so194289268wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 12:48:31 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id fq16si8188320wjc.124.2015.07.28.12.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 12:48:29 -0700 (PDT)
Date: Tue, 28 Jul 2015 21:48:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 14/14] kthread_worker: Add
 set_kthread_worker_scheduler*()
Message-ID: <20150728194820.GE19282@twins.programming.kicks-ass.net>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-15-git-send-email-pmladek@suse.com>
 <20150728174154.GG5322@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728174154.GG5322@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 28, 2015 at 01:41:54PM -0400, Tejun Heo wrote:
> On Tue, Jul 28, 2015 at 04:39:31PM +0200, Petr Mladek wrote:
> > +/**
> > + * set_kthread_worker_scheduler - change the scheduling policy and/or RT
> > + *	priority of a kthread worker.
> > + * @worker: target kthread_worker
> > + * @policy: new policy
> > + * @sched_priority: new RT priority
> > + *
> > + * Return: 0 on success. An error code otherwise.
> > + */
> > +int set_kthread_worker_scheduler(struct kthread_worker *worker,
> > +				 int policy, int sched_priority)
> > +{
> > +	return __set_kthread_worker_scheduler(worker, policy, sched_priority,
> > +					      true);
> > +}
> 
> Ditto.  I don't get why we would want these thin wrappers.

On top of which this is an obsolete interface :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
