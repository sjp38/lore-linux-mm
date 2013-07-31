Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B68106B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:50:28 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:50:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] sched, numa: migrates_degrades_locality()
Message-ID: <20130731085018.GW3008@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-8-git-send-email-mgorman@suse.de>
 <20130725104009.GO27075@twins.programming.kicks-ass.net>
 <20130731084411.GG2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130731084411.GG2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 31, 2013 at 09:44:11AM +0100, Mel Gorman wrote:
> On Thu, Jul 25, 2013 at 12:40:09PM +0200, Peter Zijlstra wrote:
> > 
> > Subject: sched, numa: migrates_degrades_locality()
> > From: Peter Zijlstra <peterz@infradead.org>
> > Date: Mon Jul 22 14:02:54 CEST 2013
> > 
> > It just makes heaps of sense; so add it and make both it and
> > migrate_improve_locality() a sched_feat().
> > 
> 
> Ok. I'll be splitting this patch and merging part of it into "sched:
> Favour moving tasks towards the preferred node" and keeping the
> degrades_locality as a separate patch. I'm also not a fan of the
> tunables names NUMA_FAULTS_UP and NUMA_FAULTS_DOWN because it is hard to
> guess what they mean. NUMA_FAVOUR_HIGHER, NUMA_RESIST_LOWER?

Sure, I don't much care about the names.. ideally you'd never use them
anyway ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
