From: Rusty Russell <rusty@linuxcare.com.au>
Subject: Re: the new VMt 
In-reply-to: Your message of "Mon, 25 Sep 2000 09:35:53 PDT."
             <Pine.LNX.4.10.10009250931570.1739-100000@penguin.transmeta.com>
Date: Wed, 27 Sep 2000 18:14:12 +1100
Message-Id: <20000927071413.A990A8146@halfway.linuxcare.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.10.10009250931570.1739-100000@penguin.transmeta.com> you
 write:
> I suspect that the proper way to do this is to just make another gfp_flag,
> which is basically another hint to the mm layer that we're doing a multi-
> page allocation and that the MM layer should not try forever to handle it.
> 
> In fact, that's independent of whether it is a multi-page allocation or
> not. It might be something like __GFP_SOFT - you could use it with single
> pages too. 

That'd be a lovely interface, now wouldn't it?

*yecch*

Please consider at least:

/* Never fails. */
#define trivial_kmalloc(s)	\
	 ((void)((s) > PAGE_SIZE ? bad_size_##s : __kmalloc((s), GFP_KERNEL)))

/* Can fail */
#define kmalloc(s, pri) __kmalloc((s), (pri)|__GFP_SOFT)

Rusty.
--
Hacking time.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
