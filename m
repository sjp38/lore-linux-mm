Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADFA6B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 17:33:31 -0500 (EST)
Received: by wmww144 with SMTP id w144so92552720wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 14:33:31 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id 190si7947248wmb.18.2015.11.18.14.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 14:33:30 -0800 (PST)
Date: Wed, 18 Nov 2015 23:32:28 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 01/22] timer: Allow to check when the timer callback
 has not finished yet
In-Reply-To: <1447853127-3461-2-git-send-email-pmladek@suse.com>
Message-ID: <alpine.DEB.2.11.1511182331010.3761@nanos>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com> <1447853127-3461-2-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 18 Nov 2015, Petr Mladek wrote:
> timer_pending() checks whether the list of callbacks is empty.
> Each callback is removed from the list before it is called,
> see call_timer_fn() in __run_timers().
> 
> Sometimes we need to make sure that the callback has finished.
> For example, if we want to free some resources that are accessed
> by the callback.
> 
> For this purpose, this patch adds timer_active(). It checks both
> the list of callbacks and the running_timer. It takes the base_lock
> to see a consistent state.
> 
> I plan to use it to implement delayed works in kthread worker.
> But I guess that it will have wider use. In fact, I wonder if
> timer_pending() is misused in some situations.

Well. That's nice and good. But how will that new function solve
anything? After you drop the lock the state is not longer valid.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
