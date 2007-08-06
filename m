Date: Mon, 6 Aug 2007 14:05:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <1186431992.7182.33.camel@twins>
Message-ID: <Pine.LNX.4.64.0708061404300.3116@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <200708061121.50351.phillips@phunq.net>
  <Pine.LNX.4.64.0708061141511.3152@schroedinger.engr.sgi.com>
 <200708061148.43870.phillips@phunq.net>  <Pine.LNX.4.64.0708061150270.7603@schroedinger.engr.sgi.com>
  <20070806201257.GG11115@waste.org>  <Pine.LNX.4.64.0708061315510.7603@schroedinger.engr.sgi.com>
 <1186431992.7182.33.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, Daniel Phillips <phillips@phunq.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Peter Zijlstra wrote:

> > The solution may be as simple as configuring the reserves right and 
> > avoid the unbounded memory allocations. 
> 
> Which is what the next series of patches will be doing. Please do look
> in detail at these networked swap patches I've been posting for the last
> year or so.
> 
> > That is possible if one 
> > would make sure that the network layer triggers reclaim once in a 
> > while.
> 
> This does not make sense, we cannot reclaim from reclaim.

But we should limit the amounts of allocation we do while performing 
reclaim. F.e. refilling memory pools during reclaim should be disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
