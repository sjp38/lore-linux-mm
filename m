Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDD156B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 15:49:08 -0400 (EDT)
Date: Tue, 4 Aug 2009 13:18:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
 script for page-allocator-related ftrace events
Message-Id: <20090804131818.ee5d4696.akpm@linux-foundation.org>
In-Reply-To: <20090804195717.GA5998@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
	<1249409546-6343-5-git-send-email-mel@csn.ul.ie>
	<20090804112246.4e6d0ab1.akpm@linux-foundation.org>
	<20090804195717.GA5998@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl, fweisbec@gmail.com, rostedt@goodmis.org, mel@csn.ul.ie, lwoodman@redhat.com, riel@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Aug 2009 21:57:17 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> Let me demonstrate these features in action (i've applied the 
> patches for testing to -tip):

So?  The fact that certain things can be done doesn't mean that there's
a demand for them, nor that anyone will _use_ this stuff.

As usual, we're adding tracepoints because we feel we must add
tracepoints, not because anyone has a need for the data which they
gather.

There is some benefit in providing MM developers with some code which
they can copy-n-paste for their day-to-day activity.  But as I said,
they can do that with vmstat too.


If we can get rid of vmstat all together (and meminfo) and replace all
that with common infrastructure then that would be a good cleanup.  But
if we end up leaving vmstat and meminfo in place and then adding
_another_ statistic gathering mechanism in parallel then we haven't
cleaned anything up at all - it just gets worse.


I don't really oppose the patches - they're small.  But they seem
rather useless too.

It would be nice to at least partially remove the vmstat/meminfo
infrastructure but I don't think we can do that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
