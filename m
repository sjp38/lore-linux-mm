Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B40B96B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 18:36:50 -0400 (EDT)
Date: Mon, 5 Apr 2010 18:33:59 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100405223359.GH21620@think>
References: <patchbomb.1270168887@v2.random>
 <20100405120906.0abe8e58.akpm@linux-foundation.org>
 <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <20100405210133.GE21620@think>
 <4BBA53A0.8050608@redhat.com>
 <alpine.LFD.2.00.1004051431030.21411@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004051431030.21411@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 02:33:29PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 6 Apr 2010, Avi Kivity wrote:
> > 
> > Please run them in conjunction with Mel Gorman's memory compaction, otherwise
> > fragmentation may prevent huge pages from being instantiated.
> 
> .. and then please run them in conjunction with somebody doing "make -j16" 
> on the kernel at the same time, or just generally doing real work for a 
> few days before hand.
> 
> The point is, there are benchmarks, and then there is real life. If we 
> _know_ some feature only works for benchmarks, it should be discounted as 
> such. It's like a compiler that is tuned for specint - at some point the 
> numbers lose a lot of their meaning.

Sure, I'll do my best to be brutal.  Avi, Andrea please fire off to me a
git tree or patch bomb for benchmarking.  Please include all the patches you
think it needs to go fast, including any config hints etc...

If you'd like numbers with and without a given set of patches, just let
me know.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
