Message-ID: <39D8FC19.CD089EB6@mountain.net>
Date: Mon, 02 Oct 2000 17:20:25 -0400
From: Tom Leete <tleete@mountain.net>
MIME-Version: 1.0
Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010021250180.22539-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Linus removed from CC]
Rik van Riel wrote:
> 
> On Mon, 2 Oct 2000, Tom Leete wrote:
> 
> > I ran lmbench on test9-pre7 with and without the patch.
> >
> > Test machine was a slow medium memory UP box:
> > Cx586@120Mhz, no optimizations, 56M
> >
> > I still experience instability on this machine with both the
> > patched and vanilla kernel. It usually takes the form of
> > sudden total lockups, but on occasion I have seen oops +
> > panic at boot.
> 
> If you could decode the oops or mail us the panic, we
> might find out if this is a VM related problem or not...

I posted one to l-k recently. Time pressure prevented me
getting these.
No guarantee they are the same.

The lockups are clearly from irq handlers. They seem
associated with ide and net.

> 
> > This summary doesn't show any performance advantage to the
> > patch, but the detailed plots show that memory access
> > latency degrades more gracefully wrt array size.
> 
> That's because this benchmark has a very artificial page
> access pattern, that doesn't really benefit from any kind
> of page replacement. ;)
> 

The memory access latency issue showed up clearly. Without
the patch it is a step function at 16k array size. It looks
like vanilla always page faults for allocations bigger than
that. Your patch knocks the corner off that.

It's supposed to be easy to add tests to lmbench, but I've
never done it.

Cheers,
Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
