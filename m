Date: Mon, 15 Jan 2001 10:24:45 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: swapout selection change in pre1
Message-ID: <20010115102445.B18014@pcep-jamie.cern.ch>
References: <01011420222701.14309@oscar> <Pine.LNX.4.10.10101141845010.4957-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101141845010.4957-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Sun, Jan 14, 2001 at 06:48:07PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> > While we may not want to treat each thread as if it was a 
> > process, I think we need more than one scan per group of threads sharing 
> > memory.  

> No, what we _really_ want is to penalize processes that have high
> page-fault ratios: it indicates that they have a big working set, which in
> turn is the absolute best way to find a memory hog in low-memory
> conditions.

Freeing pages aggressively from a process that's paging lots will make
that process page more, meaning more aggressive freeing etc. etc.
Either it works and reduces overall paging fairly (great), it spirals
out of control, which will be obvious, or it'll simply be stable at many
different rates which is undesirable but not so obvious in testing.

Perhaps the fair thing would be to not give a group of 35 threads 35
times as much CPU as someone else's single process.  The shared VM would
then fault much as if there were a single process doing user space
threading (or Python continuations or...).  That may still mean a larger
working set than a typical normal process, or it may not.  But at least
fault rate based paging heuristics wouldn't be skewed by unfair
allocation of CPU time.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
