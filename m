Date: Sat, 6 Nov 2004 01:59:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041106095913.GB2890@holomorphy.com>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au> <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au> <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418C9DFF.5010809@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418C9DFF.5010809@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 08:48:47PM +1100, Nick Piggin wrote:
> Seems like a pretty good idea to me. Optimising the fast path is what we've
> always done, especially when keeping /proc stats. Maybe this would make the
> /proc cost prohibitive though? (Hopefully not).
> What I was thinking of doing was to keep per-CPU magazines, and use them to
> amortise operations to a global atomic counter. That would drift, be
> inaccurate, and possibly go negative (without more logic). Obviously far
> more unwieldily (and basically crap) compared to your elegant solution.

Doing all the statistics by walking through a process' virtual memory
from /proc/ routines was what we started with in 2.4

Reverting it all is a huge step backward. It was done because the
/proc/ cost is in fact prohibitive.

And, of course, I fully appreciate being omitted from the thread
dedicated to backing out my work.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
