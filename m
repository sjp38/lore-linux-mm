Subject: Re: Comment on patch to remove nr_async_pages limit
References: <Pine.LNX.4.21.0106042142550.2521-100000@freak.distro.conectiva>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 05 Jun 2001 17:56:46 +0200
In-Reply-To: <Pine.LNX.4.21.0106042142550.2521-100000@freak.distro.conectiva> (Marcelo Tosatti's message of "Mon, 4 Jun 2001 22:04:22 -0300 (BRT)")
Message-ID: <877kyqzzr5.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> Zlatko, 
> 
> I've read your patch to remove nr_async_pages limit while reading an
> archive on the web. (I have to figure out why lkml is not being delivered
> correctly to me...)
> 
> Quoting your message: 
> 
> "That artificial limit hurts both swap out and swap in path as it
> introduces synchronization points (and/or weakens swapin readahead),
> which I think are not necessary."
> 
> If we are under low memory, we cannot simply writeout a whole bunch of
> swap data. Remember the writeout operations will potentially allocate
> buffer_head's for the swapcache pages before doing real IO, which takes
> _more memory_: OOM deadlock. 
> 

My question is: if we defer writing and in a way "loose" that 4096
bytes of memory (because we decide to keep the page in the memory for
some more time), how can a much smaller buffer_head be a problem?

I think we could always make a bigger reserve of buffer heads just for
this purpose, to make swapout more robust, and then don't impose any
limits on the number of the outstanding async io pages in the flight.

Does this make any sense?

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
