Message-ID: <419EBBE0.4010303@yahoo.com.au>
Date: Sat, 20 Nov 2004 14:37:04 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V11 [0/7]: overview
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com> <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <20041120020306.GA2714@holomorphy.com>
In-Reply-To: <20041120020306.GA2714@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Fri, Nov 19, 2004 at 11:59:03AM -0800, Linus Torvalds wrote:
> 
>>You could also make "rss" be a _signed_ integer per-thread.
>>When unmapping a page, you decrement one of the threads that shares the mm 
>>(doesn't matter which - which is why the per-thread rss may go negative), 
>>and when mapping a page you increment it.
>>Then, anybody who actually wants a global rss can just iterate over
>>threads and add it all up. If you do it under the mmap_sem, it's stable,
>>and if you do it outside the mmap_sem it's imprecise but stable in the
>>long term (ie errors never _accumulate_, like the non-atomic case will 
>>do).
>>Does anybody care enough? Maybe, maybe not. It certainly sounds a hell of 
>>a lot better than the periodic scan.
> 
> 
> Unprivileged triggers for full-tasklist scans are NMI oops material.
> 

Hang on, let's come back to this...

We already have unprivileged do-for-each-thread triggers in the proc
code. It's in do_task_stat, even. Rss reporting would basically just
involve one extra addition within that loop.

So... hmm, I can't see a problem with it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
