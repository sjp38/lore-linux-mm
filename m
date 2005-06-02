Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
	<429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au>
	<423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au>
	<434510000.1117670555@flay>
From: Andi Kleen <ak@muc.de>
Date: Thu, 02 Jun 2005 20:28:26 +0200
In-Reply-To: <434510000.1117670555@flay> (Martin J. Bligh's message of "Wed,
 01 Jun 2005 17:02:35 -0700")
Message-ID: <m14qcgwr3p.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: jschopp@austin.ibm.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@mbligh.org> writes:

> It gets very messy when CIFS requires a large buffer to write back
> to disk in order to free memory ...

How about just fixing CIFS to submit memory page by page? The network
stack below it supports that just fine and the VFS above it does anyways, 
so it doesnt make much sense that CIFS sitting below them uses
larger buffers.

> There's one example ... we can probably work around it if we try hard
> enough. However, the fundamental question becomes "do we support higher
> order allocs, or not?". If not fine ... but we ought to quit pretending
> we do. If so, then we need to make them more reliable.

My understanding was that the deal was that order 1 is supposed
to work but somewhat slower, and bigger orders are supposed to work
at boot up time.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
