Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 020726B01E2
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:02:15 -0400 (EDT)
Date: Fri, 15 May 2009 02:02:11 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap has unexpected holes
Message-ID: <20090514170211.GA5129@linux-sh.org>
References: <20090505082944.GA25904@csn.ul.ie> <20090505110653.GA16649@cmpxchg.org> <20090506143059.GB20709@csn.ul.ie> <20090506155043.GA3084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090506155043.GA3084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, linux@arm.linux.org.uk, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk, Badari Pulavarty <pbadari@us.ibm.com>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 05:50:43PM +0200, Johannes Weiner wrote:
> On Wed, May 06, 2009 at 03:31:00PM +0100, Mel Gorman wrote:
> > As it turns out, ARM has its own show_mem(). I don't see how, but ARM
> > must not be using lib/show_mem.c even though it compiles it.
> 
> It's some linker magic for lib/.  It compiles both but treats the
> library version as weak symbol (or something).
> 
This is true for lib-y handling in general, which lib/show_mem.o falls
under. Much of lib/ is obj-y though due to the fact that EXPORT_SYMBOL's
from lib-y are ineffective (people seem to get bitten by this at least
once a week), as a result, many things that start out as lib-y are
gradually moved over to obj-y, meaning that __weak annotations in obj-y
objects start to take precedent over lib-y magic anyways.. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
