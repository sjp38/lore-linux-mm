Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA03635
	for <linux-mm@kvack.org>; Mon, 13 Jul 1998 09:16:57 -0400
Date: Mon, 13 Jul 1998 12:54:17 +0100
Message-Id: <199807131154.MAA06026@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980709223502.29519A-100000@mirkwood.dummy.home>
References: <199807082211.XAA14327@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980709223502.29519A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 9 Jul 1998 22:39:10 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
>> <H.H.vanRiel@phys.uu.nl> said:
>> 
>> > When my zone allocator is finished, it'll be a piece of
>> > cake to implement lazy page reclamation.
>> 
>> I've already got a working implementation.  The issue of lazy
>> reclamation is pretty much independent of the allocator underneath; I

> We really should integrate this _now_, with the twist
> that pages which could form a larger buddy should be
> immediately deallocated.

Perhaps, but I don't think Linus will take it.  He's right, too, it's
too near 2.2 for that.

> This can give us a cheap way to:
> - create larger memory buddies
> - remove some of the pressure on the buddy allocator
>   (no need to grab that last 64 kB area when 25% of
>   user pages are lazy reclaim)

All it can do is to reduce the pain of doing swapping too aggressively.
It doesn't make it much easier to do true defragmentation; it just lets
you hang on to the defragmented pages a bit longer, which is a different
thing.  If you end up with non-pagable pages allocated to
kmalloc/slab/page tables all over memory, then lazy reclaim is powerless
to help defrag the memory.  We need something else for 2.2.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
