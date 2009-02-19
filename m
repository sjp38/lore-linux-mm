Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6C0556B009E
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 19:05:18 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1J05FwB001288
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Feb 2009 09:05:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 38BCD45DD72
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:05:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 17C1345DE4F
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:05:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3B4E1DB803E
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:05:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A72321DB8040
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:05:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <1234944569.24030.20.camel@penberg-laptop>
References: <20090218093858.8990.A69D9226@jp.fujitsu.com> <1234944569.24030.20.camel@penberg-laptop>
Message-Id: <20090219085229.954A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Feb 2009 09:05:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Hi Pekka,

> Hi!
> 
> On Wed, 2009-02-18 at 09:48 +0900, KOSAKI Motohiro wrote:
> > I think 2 * PAGE_SIZE is best and the patch description is needed change.
> > it's because almost architecture use two pages for stack and current page
> > allocator don't have delayed consolidation mechanism for order-1 page.
> 
> Do you mean alloc_thread_info()? Not all architectures use kmalloc() to
> implement it so I'm not sure if that's relevant for this patch.
> 
> On Wed, 2009-02-18 at 09:48 +0900, KOSAKI Motohiro wrote:
> > In addition, if pekka patch (SLAB_LIMIT = 8K) run on ia64, 16K allocation 
> > always fallback to page allocator and using 64K (4 times memory consumption!).
> 
> Yes, correct, but SLUB does that already by passing all allocations over
> 4K to the page allocator.

hmhm
OK. my mail was pointless.

but why? In my understanding, slab framework mainly exist for efficient
sub-page allocation.
the fallbacking of 4K allocation in 64K page-sized architecture seems
inefficient.


> I'm not totally against 2 * PAGE_SIZE but I just worry that as SLUB
> performance will be bound to architecture page size, we will see skewed
> results in performance tests without realizing it. That's why I'm in
> favor of a fixed size that's unified across architectures.

fair point.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
