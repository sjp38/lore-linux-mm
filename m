Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id D76F96B0031
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 17:34:51 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so4708133pbb.38
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 14:34:51 -0700 (PDT)
Date: Sun, 29 Sep 2013 17:34:47 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130929173447.14accc5f@gandalf.local.home>
In-Reply-To: <20130929183634.GA15563@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130929183634.GA15563@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, 29 Sep 2013 20:36:34 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

 
> Why? Say, percpu_rw_semaphore, or upcoming changes in get_online_cpus(),
> (Peter, I think they should be unified anyway, but lets ignore this for
> now). Or freeze_super() (which currently looks buggy), perhaps something
> else. This pattern
> 

Just so I'm clear to what you are trying to implement... This is to
handle the case (as Paul said) to see changes to state by RCU and back
again? That is, it isn't enough to see that the state changed to
something (like SLOW MODE), but we also need a way to see it change
back?

With get_online_cpus(), we need to see the state where it changed to
"performing hotplug" where holders need to go into the slow path, and
then also see the state change to "no longe performing hotplug" and the
holders now go back to fast path. Is this the rational for this email?

Thanks,

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
