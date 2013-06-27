Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 91E5B6B0036
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:53:51 -0400 (EDT)
Date: Thu, 27 Jun 2013 16:53:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130627145345.GT28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372257487-9749-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> This patch favours moving tasks towards the preferred NUMA node when
> it has just been selected. Ideally this is self-reinforcing as the
> longer the the task runs on that node, the more faults it should incur
> causing task_numa_placement to keep the task running on that node. In
> reality a big weakness is that the nodes CPUs can be overloaded and it
> would be more effficient to queue tasks on an idle node and migrate to
> the new node. This would require additional smarts in the balancer so
> for now the balancer will simply prefer to place the task on the
> preferred node for a tunable number of PTE scans.

This changelog fails to mention why you're adding the settle stuff in
this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
