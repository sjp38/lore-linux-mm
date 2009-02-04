Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 49A076B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:11:50 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B4B4882C285
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:14:23 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QYONuwstv8lf for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 11:14:19 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0532A30400C
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:14:14 -0500 (EST)
Date: Wed, 4 Feb 2009 10:49:46 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <200902032307.09025.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.1.10.0902041049090.19633@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de> <200902032250.55968.nickpiggin@yahoo.com.au> <20090203120139.GM9840@csn.ul.ie> <200902032307.09025.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Nick Piggin wrote:

> > so the max_order is inclusive not exclusive. This will force the order-0
> > allocations I think you are looking for.
>
> Well, but in the case of really bad internal fragmentation in the page,
> SLAB will do order-1 allocations even if it doesn't strictly need to.
> Probably this isn't a huge deal, but I think if we do slub_min_objects=1,
> then SLUB won't care about number of objects per page, and slub_max_order=1
> will mean it stops caring about fragmentation after order-1. I think. Which
> would be pretty close to SLAB (depending on exactly how much fragmentation
> it cares about).

slub_max_order=0 will fore all possible slabs to order 0. This means that
some slabs that SLAB will run as order 1 will be order 0 under SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
