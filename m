Date: Wed, 21 Jun 2000 16:28:43 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <200006212110.OAA53717@google.engr.sgi.com>
References: <20000621210620Z131176-21003+33@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 03:59:51 PM
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621213507Z131177-21003+34@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
Jun 2000 14:10:17 -0700 (PDT)


> Okay, I will shut up since I will have to pull out old notes and books
> to convince you, but basically, here's a simple example. Say a L2 cache 
> line is 128 bytes, and each array element is 16 bytes, giving 8 array 
> elements per cache line. Say you decide to eliminate the last element,
> maybe because it is not used. So, in that space, two global integers/
> spinlocks etc are packed in after the deletion. Further assume these
> two integers are frequently updated. Looking at an SMP system that uses
> the exlusive write cache update protocol, the cache line will probably
> bounce between the different L2 caches, which is quite bad, assuming 
> that the original 8 element array was readonly, and was probably 
> coresident in all the caches.

Fascinating.  I really appreciate your taking the time to explain this to me.  

So I suppose the best way to optimize this is to make sure that "NR_GFPINDEX *
sizeof(zonelist_t)" is a multiple of the cache line size?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
