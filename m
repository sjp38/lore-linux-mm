Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id AE4B26B0033
	for <linux-mm@kvack.org>; Sat,  6 Jul 2013 06:45:25 -0400 (EDT)
Date: Sat, 6 Jul 2013 12:44:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 13/15] sched: Set preferred NUMA node based on number of
 private faults
Message-ID: <20130706104446.GS18898@dyad.programming.kicks-ass.net>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
 <1373065742-9753-14-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373065742-9753-14-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 06, 2013 at 12:09:00AM +0100, Mel Gorman wrote:
> The third reason is that multiple threads in a process will race each
> other to fault the shared page making the fault information unreliable.

Ingo and I played around with that particular issue for a while and we had a
patch that worked fairly well for cpu bound threads and made sure the
task_numa_work() thing indeed interleaved between the threads and wasn't done
by the same thread every time.

I don't know what the current code does and if that is indeed still an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
