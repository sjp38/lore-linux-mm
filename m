Date: Mon, 28 Jun 1999 22:13:15 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <Pine.LNX.4.10.9906290053180.1588-100000@laser.random>
Message-ID: <Pine.BSO.4.10.9906282203180.10964-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 1999, Andrea Arcangeli wrote:
> On Mon, 28 Jun 1999, Stephen C. Tweedie wrote:
> 
> >> if you need evidence that shrink_mmap() will keep a system running without
> >> swapping, just run 2.3.8 :) :)
> >
> >2.3.8 shows up slower on several benchmarks because of its reluctance to
> >swap.
> 
> Here the point is if you are swapping over your ramdisk or over my HD :).
> Over my HD (system+swap all in the same IDE disk) you must _avoid_ to swap
> at all costs if you care about performances.

i'm not so sure about that.  swapping out, if efficiently done, is a
series of asynchronous sequential writes.  the only performance that will
interfere with is heavily I/O-bound applications.  even so, if it gets
more pages out of an application's way, then shrink_mmap will be less
destructive to your working set, which is a *good* thing, and your caches
will perform better.

at least, that's the way i've seen it with the workloads i've been playing
with.  so, i believe that swapping (paging) is my friend, up to a point.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
