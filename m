Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75BC66B005D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:16:54 -0400 (EDT)
Date: Wed, 5 Aug 2009 11:16:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090805091635.GA16718@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <4A787D84.2030207@redhat.com> <20090804121332.46df33a7.akpm@linux-foundation.org> <20090804204857.GA32092@csn.ul.ie> <20090805074103.GD19322@elte.hu> <20090805090742.GA21950@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805090742.GA21950@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Fr?d?ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> > I.e. we'd have your patch in the end, but also with some 
> > feel-good thoughts made about it on a higher level, so that we 
> > can be reasonably sure that we have a meaningful set of 
> > tracepoints.
> 
> Ok, I think I could put together such a description for the page 
> allocator tracepoints using the leader and your mail as starting 
> points. I reckon the best place for the end result would be 
> Documentation/vm/tracepoints.txt

The canonical place for that info is Documentation/trace/ - we 
already have a collection of similar bits there:

 events.txt  kmemtrace.txt  power.txt               tracepoints.txt
 ftrace.txt  mmiotrace.txt  ring-buffer-design.txt

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
