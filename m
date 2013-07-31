Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 85C3F6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 06:03:37 -0400 (EDT)
Date: Wed, 31 Jul 2013 11:03:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/18] sched: Retry migration of tasks to CPU on a
 preferred node
Message-ID: <20130731100330.GO2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-18-git-send-email-mgorman@suse.de>
 <20130725103352.GK27075@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130725103352.GK27075@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 25, 2013 at 12:33:52PM +0200, Peter Zijlstra wrote:
> 
> Subject: stop_machine: Introduce stop_two_cpus()
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Sun Jul 21 12:24:09 CEST 2013
> 
> Introduce stop_two_cpus() in order to allow controlled swapping of two
> tasks. It repurposes the stop_machine() state machine but only stops
> the two cpus which we can do with on-stack structures and avoid
> machine wide synchronization issues.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

Clever! I did not spot any problems so will be pulling this (and
presumably the next patch) into the series. Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
