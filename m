Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1FF6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:36:37 -0400 (EDT)
Date: Sun, 11 Apr 2010 14:35:14 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100411123514.GA19676@elte.hu>
References: <4BC0E2C4.8090101@redhat.com>
 <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
 <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <4BC1BA0D.1050904@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1BA0D.1050904@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/11/2010 02:52 PM, Ingo Molnar wrote:
> >
> > Put in a different way: this slow, gradual phsyical process causes 
> > data-cache misses to become 'colder and colder': in essence a portion of 
> > the worst-case TLB miss cost gets added to the average data-cache miss 
> > cost on more and more workloads. (Even without any nested-pagetables or 
> > other virtualization considerations.) The CPU can do nothing about this - 
> > even if it stays in a golden balance with typical workloads.
> 
> This is the essence and which is why we really need transparent hugetlb.  
> Both the tlb and the caches are way to small to handle the millions of pages 
> that are common now.
>
> > This is why i think we should think about hugetlb support today and this 
> > is why i think we should consider elevating hugetlbs to the next level of 
> > built-in Linux VM support.
> 
> Agreed, with s/today/yesterday/.

Well, yes - with the caveat that i think yesterday's hugetlb patches were 
notwhere close to being mergable. (and were nowhere close to addressing the 
problems to begin with)

Andrea's patches are IMHO a game changer because they are the first thing that 
has the chance to improve a large category of workloads.

We saw it that the 10-years-old hugetlbfs and libhugetlb experiments alone 
helped very little: a Linux-only opt-in performance feature that takes effort 
[and admin space configuration ...] on the app side will almost never be taken 
advantage of to make a visible difference to the end result - it simply doesnt 
scale as a development and deployment model.

The most important thing the past 10 years of kernel development have taught 
us are that transparent, always-available, zero-app-effort kernel features are 
king. The rest barely exists.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
