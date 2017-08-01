Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 046646B0500
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 03:57:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 16so10238572pgg.8
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 00:57:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 102si18897244plb.261.2017.08.01.00.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 00:57:31 -0700 (PDT)
Date: Tue, 1 Aug 2017 09:57:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170801075728.GE6524@worktop.programming.kicks-ass.net>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
 <20170731184142.GA30943@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731184142.GA30943@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jul 31, 2017 at 02:41:42PM -0400, Johannes Weiner wrote:
> On Mon, Jul 31, 2017 at 10:31:11AM +0200, Peter Zijlstra wrote:

> > So could you start by describing what actual statistics we need? Because
> > as is the scheduler already does a gazillion stats and why can't re
> > repurpose some of those?
> 
> If that's possible, that would be great of course.
> 
> We want to be able to tell how many tasks in a domain (the system or a
> memory cgroup) are inside a memdelay section as opposed to how many

And you haven't even defined wth a memdelay section is yet..

> are in a "productive" state such as runnable or iowait. Then derive
> from that whether the domain as a whole is unproductive (all non-idle
> tasks memdelayed), or partially unproductive (some delayed, but CPUs
> are productive or there are iowait tasks). Then derive the percentages
> of walltime the domain spends partially or fully unproductive.
> 
> For that we need per-domain counters for
> 
> 	1) nr of tasks in memdelay sections
> 	2) nr of iowait or runnable/queued tasks that are NOT inside
> 	   memdelay sections

And I still have no clue..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
