Subject: Re: /dev/recycle
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org> <20000324010031.B20140@pcep-jamie.cern.ch>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 24 Mar 2000 10:14:10 +0100
In-Reply-To: Jamie Lokier's message of "Fri, 24 Mar 2000 01:00:31 +0100"
Message-ID: <qwwitycivbx.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <lk@tantalophile.demon.co.uk> writes:

> Better than MADV_FREE: /dev/recycle
> --------------------------------------------------
> 
> What about this whacky idea?
> 
> MAP_RECYCLE|MAP_ANON initially allocates pages like MAP_ANON.  Mapping
> /dev/recycle is similar (but subtly different).
> 
> MADV_DONTNEED or munmap discard private modifications, but record this
> process as the page owner.  If the process later accesses the page, a
> page is allocated again but the MAP_RECYCLE means it may return a page
> already marked as belonging to this process without clearing it.
> 
> That's better for app allocators than MADV_FREE: they're giving the
> kernel more freedom with not much loss in performance.  And the kernel
> likes this too -- no need for vmscan to release references, as the pages
> are free already.

This would only work for /dev/zero like mappings. I need it for shm
mappings.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
