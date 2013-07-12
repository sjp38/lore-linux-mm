Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D5ECE6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 06:14:57 -0400 (EDT)
Date: Fri, 12 Jul 2013 12:14:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/16] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130712101408.GV25631@dyad.programming.kicks-ass.net>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-9-git-send-email-mgorman@suse.de>
 <20130711123038.GH25631@dyad.programming.kicks-ass.net>
 <20130711130322.GC2355@suse.de>
 <20130711131158.GJ25631@dyad.programming.kicks-ass.net>
 <20130711140914.GE2355@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711140914.GE2355@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 03:09:14PM +0100, Mel Gorman wrote:
> That might be necessary when the machine is overloaded. As a
> starting point the following should retry the migrate a number of times
> until success. The retry is checked on every fault but should not fire
> more than once every 100ms.
 
Yeah, something like that might work. But getting a working imbalance bound is
important. The current very weak direct migration is the only thing that keeps
the system from massively skewing load.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
