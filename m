Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 40C5E6B01FA
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 14:01:30 -0400 (EDT)
Date: Mon, 26 Apr 2010 20:01:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100426180110.GC8860@random.random>
References: <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
 <20100425192739.GG5789@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100425192739.GG5789@random.random>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ulrich Drepper <drepper@gmail.com>
List-ID: <linux-mm.kvack.org>

Now tried with a kernel compile with gcc patched as in prev email
(stock glibc and no glibc environment parameters). Without rebooting
(still plenty of hugepages as usual).

always:

real    4m7.280s
real    4m7.520s

never:

real    4m13.754s
real    4m14.095s

So the kernel now builds 2.3% faster. As expected nothing huge here
because of gcc not using several hundred hundred mbytes of ram (unlike
translate.o or other more pathological files), and there's lots of
cpu time spent not just in gcc.

Clearly this is not done for gcc (but for JVM and other workloads with
larger working sets), but even a kernel build running more than 2%
faster I think is worth mentioning as it confirms we're heading
towards the right direction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
