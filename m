Date: Wed, 21 Jun 2000 15:59:51 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <200006212049.NAA57630@google.engr.sgi.com>
References: <20000621204734Z131177-21003+32@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 03:41:04 PM
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621210620Z131176-21003+33@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
Jun 2000 13:49:56 -0700 (PDT)


> Yes, this is saying that although we waste physical memory (which few
> people care about any more), some of the unused space is never cached,
> since it is not accessed (although hardware processor prefetches might
> change this assumption a little bit). So, valuable cache space is not 
> wasted that can be used to hold data/code that is actually used.
> 
> What I was warning you about is that if you shrink the array to the
> exact size, there might be other data that comes on the same cacheline,
> which might cause all kinds of interesting behavior (I think they call
> this false cache sharing or some such thing).

Ok, I understand your explanation, but I have a hard time seeing how false
cache sharing can be a bad thing.

If the cache sucks up a bunch of zeros that are never used, that's definitely
wasted cache space.  How can that be any better than sucking up some real data
that can be used?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
