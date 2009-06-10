Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BEA846B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 05:41:42 -0400 (EDT)
Subject: Re: [patch v3] swap: virtual swap readahead
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090610085638.GA32511@localhost>
References: <20090609190128.GA1785@cmpxchg.org>
	 <20090609193702.GA2017@cmpxchg.org> <20090610050342.GA8867@localhost>
	 <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost>
	 <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090610085638.GA32511@localhost>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 11:42:56 +0200
Message-Id: <1244626976.13761.11593.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-10 at 16:56 +0800, Wu Fengguang wrote:
> 
> Yes it worked!  But then I run into page allocation failures:
> 
> [  340.639803] Xorg: page allocation failure. order:4, mode:0x40d0
> [  340.645744] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
> [  340.651839] Call Trace:
> [  340.654289]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
> [  340.660645]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
> [  340.666472]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
> [  340.671786]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
> [  340.678746]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]

Jesse Barnes had a patch to add a vmalloc fallback to those largish kms
allocs.

But order-4 allocs failing isn't really strange, but it might indicate
this patch fragments stuff sooner, although I've seen these particular
failues before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
