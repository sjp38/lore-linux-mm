Subject: Re: madvise (MADV_FREE)
References: <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 22 Mar 2000 19:15:53 +0100
In-Reply-To: Chuck Lever's message of "Wed, 22 Mar 2000 11:24:51 -0500 (EST)"
Message-ID: <qwwk8iuna5i.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Jamie Lokier <jamie.lokier@cern.ch>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chuck

Chuck Lever <cel@monkey.org> writes:

> ok, so you're asking for a lite(TM) version of DONTNEED that
> provides the following hint to the kernel: "i may be finished with
> this page, but i may also want to reuse it immediately."

I would say "... reuse this address space immediately and you can give
me _any_ data the next time". "Any data" means probably either the old
or a zero page.

That's the optimal strategy for the memory management modules of SAP
R/3.

> function 1 (could be MADV_DISCARD; currently MADV_DONTNEED):
>   discard pages.  if they are referenced again, the process causes page
>   faults to read original data (zero page for anonymous maps).

That would be also good.

> i'm interested to hear what big database folks have to say about this.

R/3 is not a database but probably the biggest database client. Often
much bigger than the database itself.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
