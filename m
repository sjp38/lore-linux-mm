Date: Tue, 25 Mar 2008 16:49:27 -0700 (PDT)
Message-Id: <20080325.164927.249210766.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <87tziu5q37.wl%peter@chubb.wattle.id.au>
References: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
	<20080325.162244.61337214.davem@davemloft.net>
	<87tziu5q37.wl%peter@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 26 Mar 2008 10:41:32 +1100
Return-Path: <owner-linux-mm@kvack.org>
To: peterc@gelato.unsw.edu.au
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

> It's actually harder than it looks.  Ian Wienand just finished his
> Master's project in this area, so we have *lots* of data.  The main
> issue is that, at least on Itanium, you have to turn off the hardware
> page table walker for hugepages if you want to mix superpages and
> standard pages in the same region. (The long format VHPT isn't the
> panacea we'd like it to be because the hash function it uses depends
> on the page size).  This means that although you have fewer TLB misses
> with larger pages, the cost of those TLB misses is three to four times
> higher than with the standard pages.

If the hugepage is more than 3 to 4 times larger than the base
page size, which it almost certainly is, it's still an enormous
win.

> Other architectures (where the page size isn't tied into the hash
> function, so the hardware walked can be used for superpages) will have
> different tradeoffs.

Right, admittedly this is just a (one of many) strange IA64 quirk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
