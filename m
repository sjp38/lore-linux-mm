Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E0B876B0034
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:15:54 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:15:54 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7134A6E803F
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:15:46 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U9FpM6167328
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:15:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U9FmFw005413
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:15:50 -0400
Date: Tue, 30 Jul 2013 14:45:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130730091542.GA28656@linux.vnet.ibm.com>
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

Peter, 

Can you please suggest workloads that I could try which might showcase
why you hate pure process based approach?

I know numa02_SMT does regress with my patches but I think its most
my implementation fault and not a approach issue.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
