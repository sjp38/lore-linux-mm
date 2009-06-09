Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03F316B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:16:24 -0400 (EDT)
Date: Tue, 9 Jun 2009 15:55:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/16] HWPOISON: check and isolate corrupted free pages v2
Message-ID: <20090609135514.GD15219@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090603184645.68FA21D0286@basil.firstfloor.org> <20090609100229.GE14820@wotan.suse.de> <20090609130304.GF5589@localhost> <20090609132847.GC15219@wotan.suse.de> <20090609134903.GC6583@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609134903.GC6583@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 09:49:03PM +0800, Wu Fengguang wrote:
> On Tue, Jun 09, 2009 at 09:28:47PM +0800, Nick Piggin wrote:
> > And I don't think removing a free page from the page allocator is
> > too much more complex than removing a live page from the pagecache ;)
> 
> There are usable functions for doing pagecache isolations, but no one
> to isolate one specific page from the buddy system.

But it shouldn't be too hard. Anyway you wanted to reinvent your
own functions for pagecache isolations ;)


> Plus, if we did present such a function, you'll then ask for it being
> included in page_alloc.c, injecting a big chunk of dead code into the
> really hot code blocks and possibly polluting the L2 cache. Will it be

But you would say no because you like it better in your memory
isolation file ;)

> better than just inserting several lines? Hardly. Smaller text itself
> yields faster speed.

Oh speed I'm definitely thinking about, don't worry about that.

Moving hot and cold functions together could become an issue
indeed. Mostly it probably matters a little less than code
within a single function due to their size. But I think gcc
already has options to annotate this kind of thing which we
could be using.

So it's not such a good argument against moving things out of
hotpaths, or guiding in which files to place functions.

Anyway, in this case it is not a "nack" from me. Just that I
would like to see the non-fastpath code too or at least if
it can be thought about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
