Subject: Re: Extensions to mincore
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 21 Mar 2000 03:11:16 -0600
In-Reply-To: Jamie Lokier's message of "Tue, 21 Mar 2000 02:47:31 +0100"
Message-ID: <m1puso1ydn.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie.lokier@cern.ch> writes:

> > > [Aside: is there the possibility to have mincore return the "!accessed"
> > > and "!dirty" bits of each page, perhaps as bits 1 and 2 of the returned
> > > bytes?  I can imagine a bunch of garbage collection algorithms that
> > > could make good use of those bits.  Currently some GC systems mprotect()
> > > regions and unprotect them on SEGV -- simply reading the !dirty status
> > > would obviously be much simpler and faster.]

No it wouldn't.  

Dirty kernel wise means the page needs to be swapped out. Clean kernel
wise mean the page is in the swap cache, and hasn't been written
since it was swapped in.

Dirty GC wise the page has changes since the last GC pass over it.

It is very easy to conceive of a case where a dirty GC'd page swapped
out, and then swapped in before someone got to looking at it.  So
kernel Clean/Dirty has no connection with GC Clean/Dirty.

Please, please don't mess with this for a 2.4 timeframe.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
