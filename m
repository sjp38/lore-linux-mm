Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC9E06B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 06:25:01 -0400 (EDT)
Date: Mon, 12 Apr 2010 12:23:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412102353.GV5656@random.random>
References: <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
 <4BC2EFBA.5080404@redhat.com>
 <20100412100806.GU5656@random.random>
 <4BC2F1A6.3070202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2F1A6.3070202@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 01:10:46PM +0300, Avi Kivity wrote:
> On 04/12/2010 01:08 PM, Andrea Arcangeli wrote:
> > On Mon, Apr 12, 2010 at 01:02:34PM +0300, Avi Kivity wrote:
> >    
> >> The only scenario I can see where it degrades is that you have a dcache
> >> load that spills over to all of memory, then falls back leaving a pinned
> >> page in every huge frame.  It can happen, but I don't see it as a likely
> >> scenario.  But maybe I'm missing something.
> >>      
> > And in my understanding this is exactly the scenario that kernelcore=
> > should prevent from ever materialize. Providing math guarantees
> > without kernelcore= is probably futile.
> >    
> 
> Well, that forces the user to make a different boot-time tradeoff.  It's 
> unsatisfying.

Well this is just about the math guarantee, like disabling memory
overcommit to have better guarantee not to run into the oom
killer... most people won't need this but it can address the math
concerns. I think it's enough if people wants a guarantee and it won't
require using nonlinear mapping for kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
