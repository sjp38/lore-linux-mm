Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EABF96B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 11:28:24 -0400 (EDT)
Date: Sun, 11 Apr 2010 08:22:04 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: hugepages will matter more in the future
In-Reply-To: <20100411115229.GB10952@elte.hu>
Message-ID: <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>



On Sun, 11 Apr 2010, Ingo Molnar wrote:
> 
> Both Xorg, xterms and firefox have rather huge RSS's on my boxes. (Even a 
> phone these days easily has more than 512 MB RAM.) Andrea measured 
> multi-percent improvement in gcc performance. I think it's real.

Reality check: he got multiple percent with 

 - one huge badly written file being compiled that took 22s because it's 
   such a horrible monster.

 - magic libc malloc flags tghat are totally and utterly unrealistic in 
   anything but a benchmark

 - by basically keeping one CPU totally busy doing defragmentation.

Quite frankly, that kind of "performance analysis" makes me _less_ 
interested rather than more. Because all it shows is that you're willing 
to do anything at all to get better numbers, regardless of whether it is 
_realistic_ or not.

Seriously, guys.  Get a grip. If you start talking about special malloc 
algorithms, you have ALREADY LOST. Google for memory fragmentation with 
various malloc implementations in multi-threaded applications. Thinking 
that you can just allocate in 2MB chunks is so _fundamnetally_ broken that 
this whole thread should have been laughed out of the room.

Instead, you guys egg each other on.

Stop the f*cking circle-jerk already.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
