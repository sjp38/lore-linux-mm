Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36FD66B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:46:40 -0400 (EDT)
Date: Sun, 11 Apr 2010 14:46:24 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411124624.GC19676@elte.hu>
References: <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <4BC1BF93.60807@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1BF93.60807@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/11/2010 03:08 PM, Ingo Molnar wrote:
> >
> >> No one is insisting the patches aren't intrusive.  We're insisting they 
> >> bring a real benefit.  I think Linus' main objection was that hugetlb 
> >> wouldn't work due to fragmentation, and I think we've demonstrated that 
> >> antifrag/compaction do allow hugetlb to work even during a fragmenting 
> >> workload running in parallel.
> >
> > As i understood it i think Linus had three main objections:
> >
> >  1- the improvements were only shown in specialistic environments
> >     (virtualization, servers)
> 
> Servers are not specialized workloads, and neither is virtualization. [...]

As far as kernel development goes they are. ( In fact in the past few years 
virtualization has grown the nasty habbit of sometimes _hindering_ upstream 
kernel development ... I hope that will change. )

> > Applications will just bloat up to that natural size. They'll use finer 
> > default resolutions, larger internal caches, etc. etc.
> 
> Well, if this happens we'll be ready.

That's what happened in the past 20 years, and i can see no signs of that 
process stopping anytime soon.

[ Note, 'apps bloat up to natural RAM size' is a heavy simplification with a
  somewhat derogatory undertone: in reality what happens is that apps just
  grow along what are basically random vectors, and if a vector hits across
  the RAM limit [and causing a visible slowdown due to bloat] there is a 
  _pushback_ from developers/testers/users.

  The end result is that app working sets are clipped to somewhat below the 
  typical desktop RAM size, but rarely are they debloated to much below that 
  practical average threshold. So in essence 'apps fill up available RAM'. ]

Just like car traffic 'fills up' available road capacity. If there's enough 
road capacity [and fuel prices are not too high] then families (and 
businesses) will have second and third cars and wont bother optimizing their 
driving patterns.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
