From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.46476.994769.970340@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 13:01:16 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <Pine.BSO.4.10.9906282203180.10964-100000@funky.monkey.org>
References: <Pine.LNX.4.10.9906290053180.1588-100000@laser.random>
	<Pine.BSO.4.10.9906282203180.10964-100000@funky.monkey.org>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629093005.7614G@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 22:13:15 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> On Tue, 29 Jun 1999, Andrea Arcangeli wrote:
>> 
>> Here the point is if you are swapping over your ramdisk or over my HD :).
>> Over my HD (system+swap all in the same IDE disk) you must _avoid_ to swap
>> at all costs if you care about performances.

> i'm not so sure about that.  swapping out, if efficiently done, is a
> series of asynchronous sequential writes.  the only performance that will
> interfere with is heavily I/O-bound applications.  even so, if it gets
> more pages out of an application's way, then shrink_mmap will be less
> destructive to your working set, which is a *good* thing, and your caches
> will perform better.

Absolutely.  The important thing is to do enough swapping to make sure
that unused data is not kicking around in memory.  Maybe you don't want
the swapper to be active during your kernel compile, but if you have
less than a GB of physical memory then you probably want it to at least
think about swapping unused stuff out as the compilation starts.

If you defer swapping too much, you just end up doing more paging IO
since you can fit less of your working set into cache.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
