Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 713886B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:26:03 -0400 (EDT)
Date: Tue, 6 Apr 2010 15:25:48 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406052548.GC11191@laptop>
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
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 07:23:44PM -0700, Linus Torvalds wrote:
> 
> 
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

It's an interesting route to go down. With more and more virtualization,
we start to think about HV platforms as more legitimate targets for
large scale optimizations like this. On the other hand, hardware memory
virtualization is still quite young on x86 CPUs and there are still
hardware improvements down the line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
