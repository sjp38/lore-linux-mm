Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E66026B008A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:34:46 -0500 (EST)
Date: Thu, 18 Nov 2010 16:34:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 62 of 66] disable transparent hugepages by default on
	small systems
Message-ID: <20101118163424.GH8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <5791385d8111de4b5143.1288798117@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5791385d8111de4b5143.1288798117@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:37PM +0100, Andrea Arcangeli wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> On small systems, the extra memory used by the anti-fragmentation
> memory reserve and simply because huge pages are smaller than large
> pages can easily outweigh the benefits of less TLB misses.
> 

A less obvious concern is if run on a NUMA machine with asymmetric node sizes
and one of them is very small. The reserve could make the node unusable. I've
only seen it happen once in practice (via hugeadm) but it was also a <1G
machine with 4 nodes (don't ask me why).

> In case of the crashdump kernel, OOMs have been observed due to
> the anti-fragmentation memory reserve taking up a large fraction
> of the crashdump image.
> 
> This patch disables transparent hugepages on systems with less
> than 1GB of RAM, but the hugepage subsystem is fully initialized
> so administrators can enable THP through /sys if desired.
> 
> v2: reduce the limit to 512MB
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Acked-by: Avi Kiviti <avi@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
