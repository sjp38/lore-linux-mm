Message-ID: <419E9CC1.8060503@yahoo.com.au>
Date: Sat, 20 Nov 2004 12:24:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: another approach to rss : sloppy rss
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com> <419D4EC7.6020100@yahoo.com.au> <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com> <419D8C07.9040606@yahoo.com.au> <Pine.LNX.4.58.0411191116480.24095@schroedinger.engr.sgi.com> <20041119195721.GA2203@lnx-holt.americas.sgi.com>
In-Reply-To: <20041119195721.GA2203@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> On Fri, Nov 19, 2004 at 11:21:38AM -0800, Christoph Lameter wrote:

>>I think the sloppy rss approach is the right way to go.
> 
> 
> Is this really that much of a problem?  Why not leave rss as an _ACCURATE_
> count of pages.  That way stuff like limits based upon rss and accounting
> of memory usage are accurate.
> 

I think I agree. (But Christoph is right that in practice probably nobody
or very few will ever notice).

> Have we tried splitting into seperate cache lines?  How about grouped counters
> for every 16 cpus instead of a per-cpu counter as proposed by someone else
> earlier.
> 

Well, you still need to put those counters on seperate cachelines, so you
still need to pad them out quite a lot. Then as they are shared, you _still_
need to make them atomic, and they'll still be bouncing around too.

Linus' idea of a per-thread 'pages_in - pages_out' counter may prove to be
just the right solution though.

Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
