Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4D1926B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 04:56:21 -0400 (EDT)
Date: Tue, 2 Jul 2013 10:55:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130702085546.GE21726@dyad.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <20130628135422.GA21895@linux.vnet.ibm.com>
 <20130702074659.GC21726@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130702074659.GC21726@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 02, 2013 at 09:46:59AM +0200, Peter Zijlstra wrote:
> So on the biggest system I've got; 4 nodes 32 cpus:
> 
>  Performance counter stats for './numa02' (5 runs):
> 
> 3.10.0+ + patches - NO_NUMA	58.235353126 seconds time elapsed    ( +-  0.45% )
> 3.10.0+ + patches -    NUMA   17.580963359 seconds time elapsed    ( +-  0.09% )

I just 'noticed' that I included my migrate_degrades_locality patch -- the one
posted somewhere in this thread (+ compile fixes).

Let me re-run without that one to see if there's any difference.

NO_NUMA		57.961384751 seconds time elapsed    ( +-  0.64% )
   NUMA		17.482115801 seconds time elapsed    ( +-  0.15% )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
