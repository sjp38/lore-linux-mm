Date: Mon, 10 Sep 2007 12:29:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <20070905121937.GA9246@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com> <200709050220.53801.phillips@phunq.net>
 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <20070905114242.GA19938@wotan.suse.de> <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
 <20070905121937.GA9246@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Sep 2007, Nick Piggin wrote:

> Implementation issues aside, the problem is there and I would like to
> see it fixed regardless if some/most/or all users in practice don't
> hit it.

I am all for fixing the problem but the solution can be much simpler and 
more universal. F.e. the amount of tcp data in flight may be controlled 
via some limit so that other subsystems can continue to function even if 
we are overwhelmed by network traffic. Peter's approach establishes the 
limit by failing PF_MEMALLOC allocations. If that occurs then other 
subsystems (like the disk, or even fork/exec or memory management 
allocation) will no longer operate since their allocations no longer 
succeed which will make the system even more fragile and may lead to 
subsequent failures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
