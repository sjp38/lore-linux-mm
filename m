Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 47E6A6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 16:17:17 -0500 (EST)
Received: by wmww144 with SMTP id w144so85813461wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:17:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id eq8si37029514wjc.248.2015.11.25.13.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 13:17:16 -0800 (PST)
Date: Wed, 25 Nov 2015 22:16:16 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 02/22] kthread/smpboot: Do not park in
 kthread_create_on_cpu()
In-Reply-To: <1447853127-3461-3-git-send-email-pmladek@suse.com>
Message-ID: <alpine.DEB.2.11.1511252216040.12555@nanos>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com> <1447853127-3461-3-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 18 Nov 2015, Petr Mladek wrote:
> kthread_create_on_cpu() was added by the commit 2a1d446019f9a5983e
> ("kthread: Implement park/unpark facility"). It is currently used
> only when enabling new CPU. For this purpose, the newly created
> kthread has to be parked.
> 
> The CPU binding is a bit tricky. The kthread is parked when the CPU
> has not been allowed yet. And the CPU is bound when the kthread
> is unparked.
> 
> The function would be useful for more per-CPU kthreads, e.g.
> bnx2fc_thread, fcoethread. For this purpose, the newly created
> kthread should stay in the uninterruptible state.
> 
> This patch moves the parking into smpboot. It binds the thread
> already when created. Then the function might be used universally.
> Also the behavior is consistent with kthread_create() and
> kthread_create_on_node().
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
