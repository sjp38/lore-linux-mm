Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDDE6004C0
	for <linux-mm@kvack.org>; Sun,  2 May 2010 08:18:35 -0400 (EDT)
Date: Sun, 2 May 2010 14:17:15 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100502121715.GA16754@elte.hu>
References: <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
 <20100425192739.GG5789@random.random>
 <20100426180110.GC8860@random.random>
 <20100430095543.GB3423@elte.hu>
 <20100430151940.GG22108@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100430151940.GG22108@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ulrich Drepper <drepper@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>
List-ID: <linux-mm.kvack.org>


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> > I find that a very large speedup - it's much more than what i'd have 
> > expected.
> >
> > Are you absolutely 100% sure it's real? If yes, it would be nice to 
> > underline
> 
> 200% sure, at least on the phenom X4 with 1 socket 4 cores and 800mhz ddr2 
> ram! Why don't you try yourself? You've just to use aa.git + the gcc patch I 
> posted applied to gcc and nothing else. This is what I'm using in all my 
> systems to actively benefit from it already.

Well, patching GCC (and then praying for GCC to actually build & work in a 
full toolchain) is not something that's done easily within a few minutes.

I might try it, i just wanted to point out ways how you can make the numbers 
more convincing to people who dont try out your patches first hand. Was just a 
suggestion.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
