From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006212049.NAA57630@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Wed, 21 Jun 2000 13:49:56 -0700 (PDT)
In-Reply-To: <20000621204734Z131177-21003+32@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 03:41:04 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
>  * Right now a zonelist takes up less than a cacheline. We never
>  * modify it apart from boot-up, and only a few indices are used,
>  * so despite the zonelist table being relatively big, the cache
>  * footprint of this construct is very small.
> 
> But isn't that talking about the individual zonelist_t structures, not the
> entire node_zonelists array?  I mean, we're talking about 224 UNUSED array
> elements, which is much bigger than any cache line.  And since the stuff is
> never used, it's never cached either.
>

Yes, this is saying that although we waste physical memory (which few
people care about any more), some of the unused space is never cached,
since it is not accessed (although hardware processor prefetches might
change this assumption a little bit). So, valuable cache space is not 
wasted that can be used to hold data/code that is actually used.

What I was warning you about is that if you shrink the array to the
exact size, there might be other data that comes on the same cacheline,
which might cause all kinds of interesting behavior (I think they call
this false cache sharing or some such thing).

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
