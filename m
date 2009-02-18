Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C97386B005A
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 04:01:07 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1234946582.2604.423.camel@ymzhang>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
	 <alpine.DEB.1.10.0902171120040.27813@qirst.com>
	 <1234890096.11511.6.camel@penberg-laptop>
	 <alpine.DEB.1.10.0902171204070.15929@qirst.com>
	 <1234919143.2604.417.camel@ymzhang>
	 <1234943296.24030.2.camel@penberg-laptop>
	 <1234946582.2604.423.camel@ymzhang>
Date: Wed, 18 Feb 2009 11:01:04 +0200
Message-Id: <1234947664.24030.39.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-18 at 16:43 +0800, Zhang, Yanmin wrote:
> > > Code: be 3f 06 00 00 48 c7 c7 c7 96 80 80 e8 b8 e2 f9 ff e8 c5 c2
> 45 00 9c 5b fa 65 8b 04 25 24 00 00 00 48 98 49 8b 94 c4 e8  
> > > RIP  [<ffffffff8028fae3>] kmem_cache_alloc+0x43/0x97
> > >  RSP <ffff88022f865e20>
> > > CR2: 0000000000000000
> > > ---[ end trace a7919e7f17c0a725 ]---
> > > swapper used greatest stack depth: 5376 bytes left
> > > Kernel panic - not syncing: Attempted to kill init!
> > 
> > Aah, we need to fix up some more PAGE_SHIFTs in the code.
> The new patch fixes hang issue. netperf UDP-U-4k (start CPU_NUM clients) result is pretty good.

Do you have your patch on top of it as well? Btw, can I add a Tested-by
tag from you to the patch?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
