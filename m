Message-ID: <3D26304C.51FAE560@zip.com.au>
Date: Fri, 05 Jul 2002 16:48:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D24F869.2538BC08@zip.com.au> <Pine.LNX.4.44L.0207042244590.6047-100000@imladris.surriel.com> <3D2501FA.4B14EB14@zip.com.au> <20020705231113.GA25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Thu, Jul 04, 2002 at 07:18:34PM -0700, Andrew Morton wrote:
> > Of course, that change means that we wouldn't be able to throttle
> > page allocators against IO any more, and we'd have to do something
> > smarter.  What a shame ;)
> 
> This is actually necessary IMHO. Some testing I've been able to do seems
> to reveal the current throttling mechanism as inadequate.
> 

I don't think so.  If you're referring to the situation where your
4G machine had 3.5G dirty pages without triggering writeback.

That's not a generic problem.  It's something specific to your
setup.  You're going to have to repeat it and stick some printk's
into balance_dirty_pages().  No other way of finding it.

Possibly it's an arith overflow in there, but I more suspect that
your nr_pagecache_pages() function is returning an incorrect value.

This happened to David M-T just this week in the 2.4 kernel - the
nr_buffermem_pages() function was returning a bad value due to an
unaccounted-for hole in the memory map and the observed effect
was just the same.

So.  Please debug it.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
