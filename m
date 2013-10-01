Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id DD6B06B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 10:48:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7291740pbb.28
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 07:48:38 -0700 (PDT)
Date: Tue, 1 Oct 2013 16:48:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001144820.GP3657@laptop.programming.kicks-ass.net>
References: <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
 <20131001035604.GW19582@linux.vnet.ibm.com>
 <20131001141429.GA32423@redhat.com>
 <20131001144537.GC5790@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001144537.GC5790@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Oct 01, 2013 at 07:45:37AM -0700, Paul E. McKenney wrote:
> If you don't have cpuhp_seq, you need some other way to avoid
> counter overflow.  Which might be provided by limited number of
> tasks, or, on 64-bit systems, 64-bit counters.

How so? PID space is basically limited to 30 bits, so how could we
overflow a 32bit reference counter?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
