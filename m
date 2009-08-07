Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E6A136B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:25:28 -0400 (EDT)
Date: Fri, 7 Aug 2009 15:25:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] tracing, documentation: Add a document describing
	how to do some performance analysis with tracepoints
Message-ID: <20090807142534.GB24148@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-6-git-send-email-mel@csn.ul.ie> <20090807080707.GB21821@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807080707.GB21821@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Fr?d?ric Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard@elte.hu, Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 10:07:07AM +0200, Ingo Molnar wrote:
> > <SNIP>
> 
> This is a very nice and comprehensive description!
> 

Thanks, you did write a nice chunk of it yourself though :)

> I'm wondering: would you mind if we integrated the analysis ideas 
> from your perl script into 'perf trace'? Those kinds of high-level 
> counts and summaries are useful not just for MM events.
> 

Of course not. Part of the motivation for doing the perl script was as a
POC for the gathering of high-level events. In the event such sample
scripts work out, it'd justify the greater effort to integrate them into
perf.

> Another thing that was raise dbefore is a 'perf mem' special-purpose 
> tool to help the analysis of all things memory related: leak 
> detection, high level stats, etc. That could have some turn-key 
> modes of analysis for the page allocator too.
> 

Again, my vague notion was to prototype such things in perl and then when it
works out to incorporate it in perf if suitable. As high-level gathering of
information is just a state machine, it's conceivable that some of the code
could be auto-generated.

> perf will do a proper format-string evaluation of 
> /debug/tracing/events/*/format as well, thus any tweaks to the 
> tracepoints get automatically adopted to.
> 

Which would be a major plus.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
