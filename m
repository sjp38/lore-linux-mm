Subject: Re: madvise (MADV_FREE)
References: <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org> <qwwk8iuna5i.fsf@sap.com> <20000322193016.A7368@pcep-jamie.cern.ch>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 23 Mar 2000 17:56:12 +0100
In-Reply-To: Jamie Lokier's message of "Wed, 22 Mar 2000 19:30:16 +0100"
Message-ID: <qwwaejplj6b.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie.lokier@cern.ch> writes:
> Christoph Rohland wrote:
> > > ok, so you're asking for a lite(TM) version of DONTNEED that
> > > provides the following hint to the kernel: "i may be finished
> > > with this page, but i may also want to reuse it immediately."
> > 
> > I would say "... reuse this address space immediately and you can
> > give me _any_ data the next time". "Any data" means probably
> > either the old or a zero page.
> 
> For maximum performance that's right.  But Linux normally has to
> provide some minimal security, so an application should only see its
> own data or zeros, not an arbitrary page.

That was the reason for "...probably either the old or a zero page"

> Zeroing has another advantage: you can efficiently detect it.  So
> you can use it for cached memory objects too in a number of cases,
> not just free memory.  (A bit from mincore would also allow
> detection, but not nearly as efficiently).
> 
> > That's the optimal strategy for the memory management modules of
> > SAP R/3.
> 
> Excellent!  A hard core recommendation :-)

:-)

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
