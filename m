Date: Tue, 20 Jan 2004 14:11:59 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: Memory management in 2.6
Message-ID: <20040120131159.GA5572@k3.hellgate.ch>
References: <400CB3BD.4020601@cyberone.com.au> <20040119205855.37524811.akpm@osdl.org> <400CB730.4010201@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <400CB730.4010201@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jan 2004 16:05:52 +1100, Nick Piggin wrote:
> 
> Andrew Morton wrote:
> 
> >Nick Piggin <piggin@cyberone.com.au> wrote:
> >
> >>loads should be runnable on about 64MB, preferably give decently
> >>repeatable results in under an hour.
> >
> >In under three minutes, IMO.
> 
> That would be nice, but sometimes hard, with multiple processes
> and fairly heavy swapping load.

efax exhibits a much higher run time variance in 2.6 than in 2.4, and
that's only one process. The reason we can't say anything conclusive
after three minutes is not a lack of short benchmarks, but the fact
that most benchmarks need to be repeated a dozen times to get reliable
numbers.

> would be preferable to "do something for 2 minutes and measure how
> far we got", but kbuild doesn't lend itself particularly well to
> that.

What you can do for kbuild is to build only part of it. I used something
like:

rm arch/*/*/*.o arch/i386/boot/bzImage
time make -j24

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
