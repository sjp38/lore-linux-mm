Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 80A616B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:22:13 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3637772pwi.14
        for <linux-mm@kvack.org>; Sat, 10 Apr 2010 13:22:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100410200037.GO5708@random.random>
References: <20100405232115.GM5825@random.random> <20100406011345.GT5825@random.random>
	<alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
	<alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
	<20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random>
	<20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com>
	<20100410194751.GA23751@elte.hu> <20100410200037.GO5708@random.random>
From: Jason Garrett-Glaser <darkshikari@gmail.com>
Date: Sat, 10 Apr 2010 13:21:52 -0700
Message-ID: <u2y28f2fcbc1004101321w33f73462sd4c528c0a918c2b6@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

>> (i've Cc:-ed x264 benchmarking experts - in case i missed something)
>
> It definitely worth trying... nice idea. But we need glibc to increase
> vm_end in 2M aligned chunk, otherwise we've to workaround it in the
> kernel, for short lived allocations like gcc to take advantage of
> this. I managed to get 200M of gcc (of ~500M total) of translate.o
> into hugepages with two glibc params, but I want it all in transhuge
> before I measure it. I'm running it on the workstation that had 1 day
> and half of uptime and it's still building more packages as I write
> this and running large vfs loads in /usr and maildir.
>

Just an FYI on this--if you're testing x264, it performs _all_ memory
allocation on init and never mallocs again, so it's a good testbed for
something that uses a lot of memory but doesn't malloc/free a lot.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
