Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C90706B005C
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 11:50:43 -0400 (EDT)
Date: Thu, 6 Aug 2009 16:50:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090806155048.GB6915@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <20090804195717.GA5998@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090804195717.GA5998@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Fr?d?ric Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 04, 2009 at 09:57:17PM +0200, Ingo Molnar wrote:

> <SNIP>
> 
> Let me demonstrate these features in action (i've applied the 
> patches for testing to -tip):
> 

Nice demo!

I blatently stole the guts of your mail and made it part of a more general
document on using tracepoints for analysis. It will included the patch with
the next set.

> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
