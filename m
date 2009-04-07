Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F17D5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:36:24 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:36:51 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [8/16] POISON: Add various poison checks in mm/memory.c
Message-ID: <20090407203651.GA4415@cmpxchg.org>
References: <20090407509.382219156@firstfloor.org> <20090407151005.4E24B1D046D@basil.firstfloor.org> <20090407190330.GB3818@cmpxchg.org> <20090407193145.GU17934@one.firstfloor.org> <20090407201708.GA4220@cmpxchg.org> <20090407202449.GX17934@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407202449.GX17934@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 10:24:49PM +0200, Andi Kleen wrote:
> > I think we missed each other here.  I wasn't talking about _why_ you
> > take that reference -- that is clear.  But I see these two
> > possibilities:
> > 
> >   a) memory_failure() is called on a page on the free list, the
> >   get_page() will trigger a bug because the refcount is 0
> 
> Ah got it now. Sorry for misreading you. That's indeed a problem.
> Fixing.
> 
> free pages was something my injector based test suite didn't cover :/

Hm, perhaps walking mem_map and poisoning pages at random? :)

> >   b) if that is not possible, the above check is not needed
> 
> There was at least one case where the process could free it anyways.
> I think. Or maybe that was something I fixed in a different way.
> It's possible this check is not needed, but it's probably safer
> to keep it (and it's all super slow path)

Ok.  I first thought it could be useful to shrink the race window
between allocating the page and installing the pte but the rest of the
poisoning code should be able to cope.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
