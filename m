Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 5BCC66B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:03:57 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:03:56 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4E72F19D8043
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:03:41 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U93pCb133238
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:03:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U93oqA010134
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:03:51 -0600
Date: Tue, 30 Jul 2013 14:33:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130730090345.GA22201@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130730082001.GG3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2013-07-30 10:20:01]:

> On Tue, Jul 30, 2013 at 10:17:55AM +0200, Peter Zijlstra wrote:
> > On Tue, Jul 30, 2013 at 01:18:15PM +0530, Srikar Dronamraju wrote:
> > > Here is an approach that looks to consolidate workloads across nodes.
> > > This results in much improved performance. Again I would assume this work
> > > is complementary to Mel's work with numa faulting.
> > 
> > I highly dislike the use of task weights here. It seems completely
> > unrelated to the problem at hand.
> 
> I also don't particularly like the fact that it's purely process based.
> The faults information we have gives much richer task relations.
> 

With just pure fault information based approach, I am not seeing any
major improvement in tasks/memory consolidation. I still see memory
spread across different nodes and tasks getting ping-ponged to different
nodes. And if there are multiple unrelated processes, then we see a mix
of tasks of different processes in each of the node.

This spreading of load as per my observation, isn't helping the
performance. This is esp true with bigger boxes and would take this as a
hint that we need to consolidate tasks for better performance.

Now I can just use the number of tasks rather than task weights as I do
with the current patchset. But I don't think that would be ideal either.
Esp this wouldn't work with Fair share scheduling.

For example: lets say there are 2 vm's running similar loads on a 2 node
machine. We would get the best performance if we could easily segregate
the load. I know all problems cannot be generalized into just this set.
My thinking is to get atleast these set of problems solved.

Do you see any alternatives other than numa faults/task weights that we
could use to better consolidate tasks?

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
