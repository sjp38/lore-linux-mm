Subject: Re: Comment on patch to remove nr_async_pages limit
References: <Pine.LNX.4.21.0106050307250.2846-100000@freak.distro.conectiva>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 05 Jun 2001 18:05:04 +0200
In-Reply-To: <Pine.LNX.4.21.0106050307250.2846-100000@freak.distro.conectiva> (Marcelo Tosatti's message of "Tue, 5 Jun 2001 03:18:58 -0300 (BRT)")
Message-ID: <87y9r6yksv.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

[snip]
> Exactly. And when we reach a low watermark of memory, we start writting
> out the anonymous memory.
>

Hm, my observations are a little bit different. I find that writeouts
happen sooner than the moment we reach low watermark, and many times
just in time to interact badly with some read I/O workload that made a
virtual shortage of memory in the first place. Net effect is poor
performance and too much stuff in the swap.

> > In experiments, speeding swapcache pages on their way helps.  Special
> > handling (swapcache bean counting) also helps. (was _really ugly_ code..
> > putting them on a seperate list would be a lot easier on the stomach:)
> 
> I agree that the current way of limiting on-flight swapout can be changed
> to perform better. 
> 
> Removing the amount of data being written to disk when we have a memory
> shortage is not nice. 
> 

OK, then we basically agree that there is a place for improvement, and
you also agree that we must be careful while trying to achieve that.

I'll admit that my patch is mostly experimental, and its best effect
is this discussion, which I enjoy very much. :)
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
