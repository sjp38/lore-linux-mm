Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <OF8BFC6C05.81791687-ON86256EB5.005A7A6C@raytheon.com>
From: Mark_H_Johnson@raytheon.com
Date: Wed, 16 Jun 2004 11:43:48 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dimitri Sivanich <sivanich@sgi.com>
List-ID: <linux-mm.kvack.org>




>Well, if you want deterministic interrupt latencies you should go for a
realtime OS.
>I know Linux is the big thing in the industry, but you're really better
off looking
>for a small Hard RT OS.  From the OpenSource world eCOS or RTEMS come to
mind.  Or even
>rtlinux/rtai if you want to run a full linux kernel as idle task.

I don't think the OP wants to run RT on Linux but has customers who want to
do so. Customers of course, are a pretty stubborn bunch and will demand to
use the system in ways you consider inappropriate. You may be arguing with
the wrong guy.

Getting back to the previous comment as well
>YAKT, sigh..  I don't quite understand what you mean with a "holdoff" so
>maybe you could explain what problem you see?  You don't like cache_reap
>beeing called from timer context?

Are you concerned so much about the proliferation of kernel threads or the
fact that this function is getting moved from the timer context to a
thread?

If the first case - one could argue that we don't need separate threads
titled
 - migration
 - ksoftirq
 - events
 - kblockd
 - aio
and so on [and now cache_reap], one per CPU if there was a mechanism to
schedule work to be done on a regular basis on each CPU. Perhaps this patch
should be modified to work with one of these existing kernel threads
instead (or collapse a few of these into a "janitor thread" per CPU).

If the second case, can you explain the rationale for the concern more
fully. I would expect moving stuff out of the timer context would be a
"good thing" for most if not all systems - not just those wanting good real
time response.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
