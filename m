Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 60DA36B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:22:58 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:22:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412082218.GA7380@elte.hu>
References: <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com>
 <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
 <4BC1F31E.2050009@redhat.com>
 <20100412074557.GA18485@elte.hu>
 <20100412081431.GT5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412081431.GT5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>


* Nick Piggin <npiggin@suse.de> wrote:

> >  2) or we accept the fact that the application space is shifting to the
> >     meta-kernels - and then we should agressively optimize Linux for those
> >     meta-kernels and not pretend that they are 'specialized'. They literally
> >     represent tens of thousands of applications apiece.
> 
> And if meta-kernels (or whatever you want to call a common or important 
> workload) see some speedup that is deemed to be worth the cost of the patch, 
> then it will probably get merged. Same as anything else.

I call a 'meta kernel' something that people code thousands of apps for, 
instead of coding on the native kernel. JVM/DBs/Firefox are such frameworks. 
(you can call it middleware i guess)

By all means they are not a 'single special-purpose workload' but represent 
literally tens of thousands of apps.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
