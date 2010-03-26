Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DA5BD6B0234
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:36:44 -0400 (EDT)
Date: Fri, 26 Mar 2010 20:34:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
Message-ID: <20100326193431.GF5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <alpine.DEB.2.00.1003261256080.31109@router.home>
 <20100326182311.GD5825@random.random>
 <alpine.DEB.2.00.1003261335210.31938@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003261335210.31938@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 01:44:23PM -0500, Christoph Lameter wrote:
> TLB pressure. Huge pages would accellerate SLUB since more objects can be
> served from the same page than before.

Agreed. I see it fallbacks to 4k instead of gradually going down, but
that was my point, doing the fallback and entry alloc_pages N without
internal buddy support would be fairly inefficient. This is why is
suggest this logic to be outside of slab/slub, in theory even slab
could be a bit faster thanks to large TLB on newly allocated slab
objects. I hope Mel's code already takes care of all of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
