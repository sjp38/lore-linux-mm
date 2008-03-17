Date: Mon, 17 Mar 2008 08:41:46 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
Message-ID: <20080317074146.GG27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015825.0C0171B41E0@basil.firstfloor.org> <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com> <20080317070208.GC27015@one.firstfloor.org> <86802c440803170017r622114bdpede8625d1a8ff585@mail.gmail.com> <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803170031u75167e5m301f65049b6d62ff@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> when node_boot_start is 512M alignment, and align is 1024M, offset
> could be 512M. it seems
> i = ALIGN(i, incr) need to do sth with offset...

It's possible that there are better fixes for this, but at least
my simple patch seems to work here. I admit I was banging my
head against this for some time and when I did the fix I just
wanted the bug to go away and didn't really go for subtleness.

The bootmem allocator is quite spaghetti in fact, it could
really need some general clean up (although it's' not quite
as bad yet as page_alloc.c)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
