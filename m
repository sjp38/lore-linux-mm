Date: Fri, 19 Nov 2004 19:46:10 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: another approach to rss : sloppy rss
Message-ID: <20041120014610.GA20576@lnx-holt.americas.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com> <419D4EC7.6020100@yahoo.com.au> <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com> <419D8C07.9040606@yahoo.com.au> <Pine.LNX.4.58.0411191116480.24095@schroedinger.engr.sgi.com> <20041119195721.GA2203@lnx-holt.americas.sgi.com> <419E9CC1.8060503@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419E9CC1.8060503@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 20, 2004 at 12:24:17PM +1100, Nick Piggin wrote:
> Well, you still need to put those counters on seperate cachelines, so you
> still need to pad them out quite a lot. Then as they are shared, you _still_
> need to make them atomic, and they'll still be bouncing around too.
> 
> Linus' idea of a per-thread 'pages_in - pages_out' counter may prove to be
> just the right solution though.

I can go with either solution.  Not sure how many cpus we can group together
before the cacheline becomes so hot that we need to fan them out.  I have
a gut feeling it is alot.

On the 2.4 kernel which SGI put together, we just changed rss to an
atomic and ensured it was in a seperate cacheline from the locks and
performance was more than adequate.  I realize a lot has changed since
2.4, but the concepts are similar.

Just my 2 cents,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
