Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 486026B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:42:57 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so2502530pab.25
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:42:56 -0700 (PDT)
Date: Mon, 23 Sep 2013 18:02:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923160254.GD9326@twins.programming.kicks-ass.net>
References: <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923105017.030e0aef@gandalf.local.home>
 <20130923145446.GX9326@twins.programming.kicks-ass.net>
 <20130923111303.04b99db8@gandalf.local.home>
 <20130923152223.GZ9326@twins.programming.kicks-ass.net>
 <20130923115908.6e710d29@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923115908.6e710d29@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 23, 2013 at 11:59:08AM -0400, Steven Rostedt wrote:
> On Mon, 23 Sep 2013 17:22:23 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > Still no point in using srcu for this; preempt_disable +
> > synchronize_sched() is similar and much faster -- its the rcu_sched
> > equivalent of what you propose.
> 
> To be honest, I sent this out last week and it somehow got trashed by
> my laptop and connecting to my smtp server. Where the last version of
> your patch still had the memory barrier ;-)

Ah, ok, yes in that case things start to make sense again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
