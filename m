Date: Mon, 6 Aug 2007 12:11:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <1186425063.11797.80.camel@lappy>
Message-ID: <Pine.LNX.4.64.0708061209230.7603@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <20070806103658.107883000@chello.nl>
  <Pine.LNX.4.64.0708061108430.25069@schroedinger.engr.sgi.com>
 <200708061121.50351.phillips@phunq.net> <1186425063.11797.80.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Daniel Phillips <phillips@phunq.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Peter Zijlstra wrote:

> > > Shudder. That can just be a desaster for NUMA. Both performance wise
> > > and logic wise. One cpuset being low on memory should not affect
> > > applications in other cpusets.
> 
> Do note that these are only PF_MEMALLOC allocations that will break the
> cpuset. And one can argue that these are not application allocation but
> system allocations.

This is global, global locking etc etc. On a large NUMA system this will 
cause significant delays. One fears that a livelock may result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
