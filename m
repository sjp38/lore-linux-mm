Date: Fri, 29 Sep 2000 11:54:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-t9p7 and mmap002 - freeze
In-Reply-To: <Pine.Linu.4.10.10009281625130.763-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0009291153250.23266-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Mike Galbraith wrote:

> Another thing I'm curious about is increasing memory pressure in
> the event of an allocation failure (retry).  Why do we do that?

We were short on free memory, so kswapd should work /harder/
to keep up with the current load.

> P.S.  in buffer.c, we do a LockPage(), but no UnlockPage() in
> the case of no_buffer_head.. is that correct?

No it isn't ;)  Thanks for pointing out this one...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
