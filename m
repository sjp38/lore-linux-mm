Date: Mon, 12 Aug 2002 17:55:02 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Broad questions about the current design
In-Reply-To: <147C8BD2-AE1D-11D6-8D07-000393829FA4@cs.amherst.edu>
Message-ID: <Pine.LNX.4.44L.0208121752480.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2002, Scott Kaplan wrote:

>   I want a simpler, non-scanning structure.  I want the CLOCK/LRU SEGQ
> structure that I described.  So I'll just go ahead and do that, as it will
> be the basis of some other experiments that I'm trying to do.  Once (if?)
> I've managed that, we can try some workloads to see what the overhead of
> scanning is vs. the overhead of minor (non-I/O) page faults for the
> inactive list references.  My prediction for the outcome is as follows:

> Anyone think this is interesting?

Absolutely.  One thing to keep in mind though is streaming
IO and things like 'find' that touch a LOT of pages once.

We probably want some kind of mechanism to prevent these
streaming IO pages to flush out the whole working set at
once.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
