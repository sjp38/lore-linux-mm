Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D20346B0234
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:56:22 -0400 (EDT)
Date: Fri, 26 Mar 2010 14:55:18 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
In-Reply-To: <20100326193431.GF5825@random.random>
Message-ID: <alpine.DEB.2.00.1003261452370.978@router.home>
References: <patchbomb.1269622804@v2.random> <alpine.DEB.2.00.1003261256080.31109@router.home> <20100326182311.GD5825@random.random> <alpine.DEB.2.00.1003261335210.31938@router.home> <20100326193431.GF5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Mar 2010, Andrea Arcangeli wrote:

> On Fri, Mar 26, 2010 at 01:44:23PM -0500, Christoph Lameter wrote:
> > TLB pressure. Huge pages would accellerate SLUB since more objects can be
> > served from the same page than before.
>
> Agreed. I see it fallbacks to 4k instead of gradually going down, but
> that was my point, doing the fallback and entry alloc_pages N without
> internal buddy support would be fairly inefficient. This is why is
> suggest this logic to be outside of slab/slub, in theory even slab
> could be a bit faster thanks to large TLB on newly allocated slab
> objects. I hope Mel's code already takes care of all of this.

SLAB's queueing system has the inevitable garbling effect on memory
references. The larger the queues the larger that effect becomes.

We already have internal buddy support in the page allocator. Mel's defrag
approach groups them together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
