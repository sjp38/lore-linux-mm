Date: Tue, 21 Mar 2000 15:41:17 +0000
From: "Stephen C. Tweedie" <sct@scot.redhat.com>
Subject: Re: Extensions to mincore
Message-ID: <20000321154117.A8113@dukat.scot.redhat.com>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com> <20000321161507.D5291@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000321161507.D5291@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Tue, Mar 21, 2000 at 04:15:07PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 21, 2000 at 04:15:07PM +0100, Jamie Lokier wrote:
> > Dirty GC wise the page has changes since the last GC pass over it.
> 
> Of course, I thought that was obvious :-)
> 
> You're right, that for GC the "!dirty" bit has to mean "since the last
> time we called mincore".

And that information is not maintained anywhere.  In fact, it basically
_can't_ be maintained, since the hardware only maintains one bit and
we already use that dirty bit.  The only way round this is to use
mprotect-style munging.

> All threads sharing a page have to synchronise their mincore calls for
> that page, but that situation is no different to the SEGV method: all
> threads have to synchronise with the information collected from that,
> too.

It's not about synchronising between mincore calls, it's about 
synchronising mincore calls on one CPU with direct memory references
modifying page tables on another CPU.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
