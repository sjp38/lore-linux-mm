Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 07DD76B0244
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 13:01:35 -0400 (EDT)
Date: Fri, 30 Apr 2010 19:00:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #22
Message-ID: <20100430170037.GJ22108@random.random>
References: <20100429144136.GA22108@random.random>
 <20100430085427.GA11032@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100430085427.GA11032@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 30, 2010 at 10:54:27AM +0200, Ingo Molnar wrote:
> It would be nice and informative to have two diffstats in the announcement:
> 
> - an 'absolute' one that shows all the hugetlb changes relative to upstream 
>   (or relative to -mm, whichever tree you use as a base),

That's easy, I will do next times. I'm based on mainline right now.

> - and [if possible] a 'delta' one that shows the diffstat to the previous
>   version you've announced. [say in this current case the #21..#22 delta 
>   diffstat] [this might not always be easy to provide, when the upstream base 
>   changes.]

I've revision control on the quilt patchset, I can send the diffstat
of the quilt patchset.

You can also monitor the changes by running:

git fetch
git diff origin/master

before "git checkout origin/master".

but as you said that will also show the new mainline changes mixed
with my changes.

> That way people can see the general direction and scope from the email, 
> without having to fetch any of the trees.

It's informative yes, but I hope that people really fetch the tree,
review the changes with "git log -p" or just blind test it and run
some benchmark. Many already did and that is the only way to get
feedback (positive or negative) and to be sure that we're going into
the right direction. The only feedback I got so far from people
testing the tree has been exceedingly positive which in addition to
the benchmarks I run myself, makes me more confident this is going in
the right direction and helping a wider scope of workloads. The
research I did initially on the prefault logic I think helped me
keeping things simpler and more efficient and I think the decision
that it was worth it do larger copy-page/clear-page only if we also
get something more than a prefault speedup in return (as those copies
slowdown the page faults and trashes the cache) is paying off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
