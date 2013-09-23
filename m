Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCC16B0036
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:06:39 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2464635pab.38
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:06:39 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:59:08 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923115908.6e710d29@gandalf.local.home>
In-Reply-To: <20130923152223.GZ9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130917162050.GK22421@suse.de>
	<20130917164505.GG12926@twins.programming.kicks-ass.net>
	<20130918154939.GZ26785@twins.programming.kicks-ass.net>
	<20130919143241.GB26785@twins.programming.kicks-ass.net>
	<20130923105017.030e0aef@gandalf.local.home>
	<20130923145446.GX9326@twins.programming.kicks-ass.net>
	<20130923111303.04b99db8@gandalf.local.home>
	<20130923152223.GZ9326@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, 23 Sep 2013 17:22:23 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Still no point in using srcu for this; preempt_disable +
> synchronize_sched() is similar and much faster -- its the rcu_sched
> equivalent of what you propose.

To be honest, I sent this out last week and it somehow got trashed by
my laptop and connecting to my smtp server. Where the last version of
your patch still had the memory barrier ;-)

So yeah, a true synchronize_sched() is better.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
