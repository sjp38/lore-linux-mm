Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708061209230.7603@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.107883000@chello.nl>
	 <Pine.LNX.4.64.0708061108430.25069@schroedinger.engr.sgi.com>
	 <200708061121.50351.phillips@phunq.net> <1186425063.11797.80.camel@lappy>
	 <Pine.LNX.4.64.0708061209230.7603@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 21:31:30 +0200
Message-Id: <1186428690.11797.96.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-06 at 12:11 -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Peter Zijlstra wrote:
> 
> > > > Shudder. That can just be a desaster for NUMA. Both performance wise
> > > > and logic wise. One cpuset being low on memory should not affect
> > > > applications in other cpusets.
> > 
> > Do note that these are only PF_MEMALLOC allocations that will break the
> > cpuset. And one can argue that these are not application allocation but
> > system allocations.
> 
> This is global, global locking etc etc. On a large NUMA system this will 
> cause significant delays. One fears that a livelock may result.

The only new lock is in SLUB, and I'm not aware of any regular
PF_MEMALLOC paths using slab allocations, but I'll instrument the
regular reclaim path to verify this.

The functionality this is aimed at is swap over network, and I doubt
you'll be enabling that on these machines.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
