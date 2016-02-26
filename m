Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 356716B0256
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:15:11 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b205so75958856wmb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:15:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h84si4588768wmf.124.2016.02.26.07.15.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 07:15:10 -0800 (PST)
Date: Fri, 26 Feb 2016 16:15:08 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 05/20] kthread: Add destroy_kthread_worker()
Message-ID: <20160226151508.GG3305@pathway.suse.cz>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-6-git-send-email-pmladek@suse.com>
 <20160225123641.GH6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225123641.GH6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 2016-02-25 13:36:41, Peter Zijlstra wrote:
> On Mon, Feb 22, 2016 at 03:56:55PM +0100, Petr Mladek wrote:
> > Also note that drain() correctly handles self-queuing works in compare
> > with flush().
> 
> Nothing seems to prevent adding more work after drain() observes
> list_empty().

You might want to drain() more times during the kthread worker life
time to make sure that the work is done.

The user is responsible for stopping any queuing when this function
is called. The user usually needs to handle this anyway because
producing a work that could not be queued would cause problems.

To be honest, I wanted to keep the main principles of the API
compatible with workqueues. It should reduce some potential confusion.
Also it will make it easier to convert between the two APIs.
IMHO, there are work loads when you are not sure if you will
need a dedicated kthread when designing a new functionality.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
