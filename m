Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF0D6B0237
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 05:56:54 -0400 (EDT)
Date: Fri, 30 Apr 2010 11:55:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100430095543.GB3423@elte.hu>
References: <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
 <20100425192739.GG5789@random.random>
 <20100426180110.GC8860@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100426180110.GC8860@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ulrich Drepper <drepper@gmail.com>
List-ID: <linux-mm.kvack.org>


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> Now tried with a kernel compile with gcc patched as in prev email
> (stock glibc and no glibc environment parameters). Without rebooting
> (still plenty of hugepages as usual).
> 
> always:
> 
> real    4m7.280s
> real    4m7.520s
> 
> never:
> 
> real    4m13.754s
> real    4m14.095s
> 
> So the kernel now builds 2.3% faster. As expected nothing huge here
> because of gcc not using several hundred hundred mbytes of ram (unlike
> translate.o or other more pathological files), and there's lots of
> cpu time spent not just in gcc.
> 
> Clearly this is not done for gcc (but for JVM and other workloads with
> larger working sets), but even a kernel build running more than 2%
> faster I think is worth mentioning as it confirms we're heading
> towards the right direction.

Was this done on a native/host kernel?

I.e. do everyday kernel hackers gain 2.3% of kbuild performance from this?

I find that a very large speedup - it's much more than what i'd have expected.

Are you absolutely 100% sure it's real? If yes, it would be nice to underline 
that by gathering some sort of 'perf stat --repeat 3 --all' kind of 
always/never comparison of those kernel builds, so that we can see where the 
+2.3% comes from.

I'd expect to see roughly the same instruction count (within noise), but a ~3% 
reduced cycle count (due to fewer/faster TLB fills).

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
