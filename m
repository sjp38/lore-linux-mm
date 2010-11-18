Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A82F6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:38:41 -0500 (EST)
Date: Wed, 17 Nov 2010 23:33:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
Message-Id: <20101117233350.321f9935.akpm@linux-foundation.org>
In-Reply-To: <20101118072706.GW13830@dastard>
References: <20101117042720.033773013@intel.com>
	<20101117150330.139251f9.akpm@linux-foundation.org>
	<20101118020640.GS22876@dastard>
	<20101117180912.38541ca4.akpm@linux-foundation.org>
	<20101118032141.GP13830@dastard>
	<20101117193431.ec1f4547.akpm@linux-foundation.org>
	<20101118072706.GW13830@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 18:27:06 +1100 Dave Chinner <david@fromorbit.com> wrote:

> > > Indeed, nobody has
> > > realised (until now) just how inefficient it really is because of
> > > the fact that the overhead is mostly hidden in user process system
> > > time.
> > 
> > "hidden"?  You do "time dd" and look at the output!
> > 
> > _now_ it's hidden.  You do "time dd" and whee, no system time!
> 
> What I meant is that the cost of foreground writeback was hidden in
> the process system time. Now we have separated the two of them, we
> can see exactly how much it was costing us because it is no longer
> hidden inside the process system time.

About a billion years ago I wrote the "cyclesoak" thingy which measures
CPU utilisation the other way around: run a lowest-priority process on
each CPU in the background, while running your workload, then find out
how much CPU time cyclesoak *didn't* consume.  That way you account for
everything: user time, system time, kernel threads, interrupts,
softirqs, etc.  It turned out to be pretty accurate, despite the
then-absence of SCHED_IDLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
