Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3ABA66B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 16:28:53 -0400 (EDT)
Date: Mon, 27 Aug 2012 17:28:35 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v9 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120827202834.GC6517@t510.redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
 <aa4af6e819584cb05fc0dba44594ae23ab761d03.1345869378.git.aquini@redhat.com>
 <20120826075557.GD19551@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120826075557.GD19551@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sun, Aug 26, 2012 at 10:55:58AM +0300, Michael S. Tsirkin wrote:
> On Sat, Aug 25, 2012 at 02:24:56AM -0300, Rafael Aquini wrote:
> > Memory fragmentation introduced by ballooning might reduce significantly
> > the number of 2MB contiguous memory blocks that can be used within a guest,
> > thus imposing performance penalties associated with the reduced number of
> > transparent huge pages that could be used by the guest workload.
> > 
> > This patch introduces a common interface to help a balloon driver on
> > making its page set movable to compaction, and thus allowing the system
> > to better leverage the compation efforts on memory defragmentation.
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> 
> Tons of rcu uses but not sync in sight. This looks suspicious.

There's no critical section marked with rcu_read_lock/rcu_read_unlock. that's
why there's no call for sync anywhere. As we are behaving mostly as updaters,
the hole rcu usage is awkward and it's placed basically to enforce the proper
order. To avoid hurting the RCU API usage with this awk approach I'll drop it
for the next series submission (it will use barriers instead).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
