From: frankeh@us.ibm.com
Message-ID: <85256905.0074AE6A.00@D51MTA03.pok.ibm.com>
Date: Wed, 21 Jun 2000 17:15:09 -0400
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur...

If [A] is located on the same cacheline as frequently accessed readonly
data, and [A] is written frequently on other processors, e.g a frequently
used lock, then in order to write to the cacheline, write access must be
obtained, which will lead to a global cache line invalidate. If [A] is now
accessed again, then the read permissions have to be obtained and the
cacheline has to be transferred back from another processor. These
interprocessor  cacheline transfers can be expensive operations. When you
go up to NUMA machines this will be even more.

Hope this helps, otherwise keep pounding..

-- Hubertus


Timur Tabi <ttabi@interactivesi.com>@kvack.org on 06/21/2000 04:59:51 PM

Sent by:  owner-linux-mm@kvack.org


To:   Linux MM mailing list <linux-mm@kvack.org>
cc:
Subject:  Re: 2.4: why is NR_GFPINDEX so large?



** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed,
21
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

If the cache sucks up a bunch of zeros that are never used, that's
definitely
wasted cache space.  How can that be any better than sucking up some real
data
that can be used?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then
I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
