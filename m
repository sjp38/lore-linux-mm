Message-ID: <419D581F.2080302@yahoo.com.au>
Date: Fri, 19 Nov 2004 13:19:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: fast path for anonymous memory allocation
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This patch conflicts with the page fault scalability patch but I could not
> leave this stone unturned. No significant performance increases so
> this is just for the record in case someone else gets the same wild idea.
> 

I had a similar wild idea. Mine was to just make sure we have a spare
per-CPU page ready before taking any locks.

Ahh, you're doing clear_user_highpage after the pte is already set up?
Won't that be racy? I guess that would be an advantage of my approach,
the clear_user_highpage can be done first (although that is more likely
to be wasteful of cache).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
