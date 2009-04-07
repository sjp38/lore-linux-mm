Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 10A305F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:22:16 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:24:49 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [8/16] POISON: Add various poison checks in mm/memory.c
Message-ID: <20090407202449.GX17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151005.4E24B1D046D@basil.firstfloor.org> <20090407190330.GB3818@cmpxchg.org> <20090407193145.GU17934@one.firstfloor.org> <20090407201708.GA4220@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407201708.GA4220@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

> I think we missed each other here.  I wasn't talking about _why_ you
> take that reference -- that is clear.  But I see these two
> possibilities:
> 
>   a) memory_failure() is called on a page on the free list, the
>   get_page() will trigger a bug because the refcount is 0

Ah got it now. Sorry for misreading you. That's indeed a problem.
Fixing.

free pages was something my injector based test suite didn't cover :/

>   b) if that is not possible, the above check is not needed

There was at least one case where the process could free it anyways.
I think. Or maybe that was something I fixed in a different way.
It's possible this check is not needed, but it's probably safer
to keep it (and it's all super slow path)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
