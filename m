Date: Wed, 22 Mar 2000 19:30:16 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322193016.A7368@pcep-jamie.cern.ch>
References: <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org> <qwwk8iuna5i.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <qwwk8iuna5i.fsf@sap.com>; from Christoph Rohland on Wed, Mar 22, 2000 at 07:15:53PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Rohland wrote:
> > ok, so you're asking for a lite(TM) version of DONTNEED that
> > provides the following hint to the kernel: "i may be finished with
> > this page, but i may also want to reuse it immediately."
> 
> I would say "... reuse this address space immediately and you can give
> me _any_ data the next time". "Any data" means probably either the old
> or a zero page.

For maximum performance that's right.  But Linux normally has to provide
some minimal security, so an application should only see its own data or
zeros, not an arbitrary page.

Zeroing has another advantage: you can efficiently detect it.  So you
can use it for cached memory objects too in a number of cases, not just
free memory.  (A bit from mincore would also allow detection, but not
nearly as efficiently).

> That's the optimal strategy for the memory management modules of SAP R/3.

Excellent!  A hard core recommendation :-)

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
