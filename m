Date: Mon, 13 May 2002 10:34:40 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] IO wait accounting
In-Reply-To: <dnvg9sfez1.fsf@magla.zg.iskon.hr>
Message-ID: <Pine.LNX.4.44L.0205131034110.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Bill Davidsen <davidsen@tmr.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 May 2002, Zlatko Calusic wrote:

> Anyway, here is how Aix defines it:
>
>  Average percentage of CPU time that the CPUs were idle during which
>  the system had an outstanding disk I/O request. This value may be
>  inflated if the actual number of I/O requesting threads is less than
>  the number of idling processors.

Ohhh, I ran into this implementation detail, too ;)

I hope that means I'm doing something right.

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
