Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 461D26B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 05:08:45 -0400 (EDT)
Date: Tue, 6 Apr 2010 11:08:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406090813.GA14098@elte.hu>
References: <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, 5 Apr 2010, Linus Torvalds wrote:
> > 
> > So I thought it was a more interesting load than it was. The 
> > virtualization "TLB miss is expensive" load I can't find it in myself to 
> > care about. "Get a better CPU" is my answer to that one,
> 
> [ Btw, I do realize that "better CPU" in this case may be "future CPU". I 
>   just think that this is where better TLB's and using ASID's etc is 
>   likely to be a much bigger deal than adding VM complexity. Kind of the 
>   same way I think HIGHMEM was ultimately a failure, and the 4G:4G split 
>   was an atrocity that should have been killed ]

Both highmem and 4g:4g were failures (albeit highly practical failures you 
have to admit) in the sense that their relevance faded over time. (because 
they extended the practical limits of the constantly fading, 32-bit world.)

Both highmem and 4g:4g became less and less of an issue as hardware improved.

OTOH are you saying the same thing about huge pages? On what basis? Do you 
think it would be possible for hardware to 'discover' physically-continuous 2M 
mappings and turn them into a huge TLB internally? [i'm not sure it's feasible 
even in future CPUs - and even if it is, the OS would still have to do the 
defrag and keep-them-2MB logic internally so there's not much difference.]

The numbers seem rather clear:

  http://lwn.net/Articles/378641/

Yes, some of it is benchmarketing (most benchmarks are), but a significant 
portion of it isnt: HPC processing, DB workloads and Java workloads.

Hugepages provide a 'final' performance boost in cases where there's no other 
software way left to speed up a given workload.

The goal of Andrea's and Mel's patch-set, to make this 'final performance 
boost' more practical seems like a valid technical goal.

We can still validly reject it all based on VM complexity (albeit the VM 
people wrote both the defrag part and the transparent usage part so all the 
patches are all real), but how can we legitimately reject the performance 
advantage?

I think the hugetlb situation is more similar to the block IO transition to 
larger sector sizes in block IO or to the networking IO transition from 
host-side-everything to checksum-offload and then to TSO - than it is similar 
to highmem or 4g:4g.

In fact the whole maintenance thought process seems somewhat similar to the 
TSO situation: the networking folks first rejected TSO based on complexity 
arguments, but then was embraced after some time.

 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
