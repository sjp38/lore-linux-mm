Message-ID: <39B4CD34.F11D4BA4@free.fr>
Date: Tue, 05 Sep 2000 12:38:45 +0200
From: Fabio Riccardi <fabio.riccardi@free.fr>
MIME-Version: 1.0
Subject: Re: zero copy IO project
References: <Pine.LNX.4.21.0009042136030.23932-100000@devserv.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ok, I can see the point, I'll stick to the current framework then. I will postpone
anything radical to when I will have a better understanding of Linux' internals
and philosophy.

Two questions:

How can I contribute? What would interest me in the short term is to build an
optimized web server, using all the possible tricks available in the current
architecture, my company needs that and is happy that I spend my time to get
things going

Where can I find some docs? Rick mentioned that you have some design papers on the
kiobuf architecture. What is available about the sendfile interface?

 - Fabio

Ben LaHaise wrote:

> Anything that requires playing VM tricks is not something you'll find a
> great deal of support for amongst developers -- see the posting Linus made
> against exactly this.
>
> It comes down to complexity and the amount of gain in generic
> applications.  Take apache for example.  Enabling "zero copy" through VM
> tricks will buy you no benefit when it comes to the http header sent out
> on a request.  But the act of transmitting a file is already well handled
> by the sendfile() model.
>
> Fwiw, there are lots of libc optimisations that are worth *more* than
> "zero copy" for typical applications.  Like pre-linking libraries.  stdio
> could make use of mmap for fread.
>
>                 -ben
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
