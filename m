Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6816B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:42:06 -0400 (EDT)
Date: Fri, 17 Jun 2011 12:40:29 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110617194029.GA28954@tassilo.jf.intel.com>
References: <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
 <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
 <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
 <1308310080.2355.19.camel@twins>
 <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 09:46:00AM -0700, Linus Torvalds wrote:
> On Fri, Jun 17, 2011 at 4:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >
> > Something like so? Compiles and runs the benchmark in question.
> 
> Oh, and can you do this with a commit log and sign-off, and I'll put
> it in my "anon_vma-locking" branch that I have. I'm not going to
> actually merge that branch into mainline until I've seen a few more
> acks or more testing by Tim.
> 
> But if Tim's numbers hold up (-32% to +15% performance by just the
> first one, and +15% isn't actually an improvement since tmpfs
> read-ahead should have gotten us to +66%), I think we have to do this
> just to avoid the performance regression.

You could also add the mutex "optimize caching protocol" 
patch I posted earlier to that branch.

It didn't actually improve Tim's throughput number, but it made the CPU 
consumption of the mutex go down. 

-Andi

---
