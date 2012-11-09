Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B09776B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 10:26:08 -0500 (EST)
Date: Fri, 9 Nov 2012 12:58:29 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 7/7] mm: add vm event counters for balloon pages
 compaction
Message-ID: <20121109145829.GC4308@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <8dde7996f3e36a5efbe569afe1aadfc84355e79e.1352256088.git.aquini@redhat.com>
 <20121109122033.GR3886@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121109122033.GR3886@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Nov 09, 2012 at 12:20:33PM +0000, Mel Gorman wrote:
> On Wed, Nov 07, 2012 at 01:05:54AM -0200, Rafael Aquini wrote:
> > This patch introduces a new set of vm event counters to keep track of
> > ballooned pages compaction activity.
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> 
> Other than confirming the thing actually works can any meaningful
> conclusions be drawn from this counters?
> 
> I know I have been inconsistent on this myself in the past but recently
> I've been taking the attitude that the counters can be used to fit into
> some other metric. I'm looking to change the compaction counters to be
> able to build a basic cost model for example. The same idea could be
> used for balloons of course but it's a less critical path than
> compaction for THP for example.
> 
> Assuming it builds and all the defines are correct when the feature is
> not configured (I didn't check) then there is nothing wrong with the
> patch. However, if it was dropped would it make life very hard or would
> you notice?
> 

Originally, I proposed this patch as droppable (and it's still droppable)
because its major purpose was solely to show the thing working consistently

OTOH, it might make the life easier to spot breakages if it remains with the
merged bits, and per a reviewer request I removed its 'DROP BEFORE MERGE'
disclaimer.

   https://lkml.org/lkml/2012/8/8/616

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
