Date: Wed, 17 Jan 2001 18:15:34 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <01011410512900.02185@oscar>
Message-ID: <Pine.LNX.4.31.0101171814030.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Jan 2001, Ed Tomlinson wrote:

> A couple of observations on the pre2/pre3 vm.  It seems to start
> swapping out very quicky but this does not seem to hurt.  Once
> there is memory preasure and swapin starts cpu utilization drops
> thru the roof - kernel compiles are only able to drive the
> system at 10-20% (UP instead of 95-100%).

Page_launder() and refill_inactive() need to be tuned so
they function well when multiple threads are calling them.

I have been working on this (independently, no internet for
a week) and have some stuff working. I will clean it up and
will try to fix the performance problems people are seeing
now.

(and I will make sure people know the reasoning behind my patch
so nobody will change things on a whim in the future ... I'd like
2.4 to remain stable)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
