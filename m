Date: Wed, 16 Jun 2004 16:29:34 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616152934.GA13527@infradead.org>
References: <20040616142413.GA5588@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040616142413.GA5588@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 09:24:13AM -0500, Dimitri Sivanich wrote:
> Hi,
> 
> In the process of testing per/cpu interrupt response times and CPU availability,
> I've found that running cache_reap() as a timer as is done currently results
> in some fairly long CPU holdoffs.
> 
> I would like to know what others think about running cache_reap() as a low
> priority realtime kthread, at least on certain cpus that would be configured
> that way (probably configured at boottime initially).  I've been doing some
> testing running it this way on CPU's whose activity is mostly restricted to
> realtime work (requiring rapid response times).
> 
> Here's my first cut at an initial patch for this (there will be other changes
> later to set the configuration and to optimize locking in cache_reap()).

YAKT, sigh..  I don't quite understand what you mean with a "holdoff" so
maybe you could explain what problem you see?  You don't like cache_reap
beeing called from timer context?

As for realtime stuff you're probably better off using something like rtlinux,
getting into the hrt or even real strong soft rt busuniness means messing up
the kernel horrible.  Given you're @sgi.com address you probably know what
a freaking mess and maintaince nightmare IRIX has become because of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
