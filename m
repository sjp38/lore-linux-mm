Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CB84D6B00CB
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 19:48:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1I0mA3D022080
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Feb 2009 09:48:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 994DC45DD75
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:48:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A13645DD72
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:48:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 821871DB8046
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:48:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 316291DB8043
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 09:48:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <alpine.DEB.1.10.0902171504090.24395@qirst.com>
References: <84144f020902171143i5844ef83h20cb4bee4f65c904@mail.gmail.com> <alpine.DEB.1.10.0902171504090.24395@qirst.com>
Message-Id: <20090218093858.8990.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Feb 2009 09:48:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 17 Feb 2009, Pekka Enberg wrote:
> 
> > >> +#define SLUB_MAX_SIZE (2 * PAGE_SIZE)
> >
> > On Tue, Feb 17, 2009 at 8:11 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > This relies on PAGE_SIZE being 4k.  If you want 8k, why don't you say
> > > so?  Pekka did this explicitely.
> >
> > That could be a problem, sure. Especially for architecture that have 64 K pages.
> 
> You could likely put a complicated formula in there instead. But 2 *
> PAGE_SIZE is simple and will work on all platforms regardless of pagesize.

I think 2 * PAGE_SIZE is best and the patch description is needed change.
it's because almost architecture use two pages for stack and current page
allocator don't have delayed consolidation mechanism for order-1 page.

In addition, if pekka patch (SLAB_LIMIT = 8K) run on ia64, 16K allocation 
always fallback to page allocator and using 64K (4 times memory consumption!).

Am I misunderstand anything?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
