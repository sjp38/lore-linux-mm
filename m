Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6E0956B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 04:20:05 -0400 (EDT)
Date: Tue, 30 Jul 2013 10:20:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130730082001.GG3008@twins.programming.kicks-ass.net>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730081755.GF3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 30, 2013 at 10:17:55AM +0200, Peter Zijlstra wrote:
> On Tue, Jul 30, 2013 at 01:18:15PM +0530, Srikar Dronamraju wrote:
> > Here is an approach that looks to consolidate workloads across nodes.
> > This results in much improved performance. Again I would assume this work
> > is complementary to Mel's work with numa faulting.
> 
> I highly dislike the use of task weights here. It seems completely
> unrelated to the problem at hand.

I also don't particularly like the fact that it's purely process based.
The faults information we have gives much richer task relations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
