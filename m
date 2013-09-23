Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id E89BC6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:31:41 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id n5so842278oag.41
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:31:41 -0700 (PDT)
Date: Mon, 23 Sep 2013 19:30:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923173014.GF9326@twins.programming.kicks-ass.net>
References: <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923105017.030e0aef@gandalf.local.home>
 <20130923145446.GX9326@twins.programming.kicks-ass.net>
 <20130923111303.04b99db8@gandalf.local.home>
 <20130923155059.GO9093@linux.vnet.ibm.com>
 <20130923160130.GC9326@twins.programming.kicks-ass.net>
 <20130923170400.GA1390@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923170400.GA1390@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 23, 2013 at 10:04:00AM -0700, Paul E. McKenney wrote:
> At some point I suspect that we will want some form of fairness, but in
> the meantime, good point.

I figured we could start a timer on hotplug to force quiesce the readers
after about 10 minutes or so ;-)

Should be a proper discouragement from (ab)using this hotplug stuff...

Muwhahaha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
