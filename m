Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 593656B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 13:01:06 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:56:20 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: hugepages will matter more in the future
In-Reply-To: <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1004120953040.26679@i5.linux-foundation.org>
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com> <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org> <4BC34837.7020108@redhat.com> <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>



On Mon, 12 Apr 2010, Linus Torvalds wrote:
> 
> So as I already commented to Andrew, the code has no comments about the 
> "big picture", and the largest comment I found was about a totally 
> _trivial_ issue about replacing the hugepage by first clearing the entry, 
> then flushing the tlb, and then filling it.

Btw, this is the same complaint I had about the anon_vma code. There was 
no overview comments, and some of my fixes to that came directly from 
writing a big-picture "what should happen" flow chart, and either noticing 
that the code didn't do what it should have done, or that even the big 
picture was not clear.

And yes, I do realize that historically we (I) haven't been good at those 
things. It's just that the VM has gotten _so_ complicated that we damn 
well need them, at least when we add new features that the rest of the VM 
team doesn't know by rote.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
