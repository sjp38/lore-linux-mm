From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 11:21:50 -0700
References: <20070806102922.907530000@chello.nl> <20070806103658.107883000@chello.nl> <Pine.LNX.4.64.0708061108430.25069@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708061108430.25069@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061121.50351.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 11:11, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Peter Zijlstra wrote:
> > Change ALLOC_NO_WATERMARK page allocation such that dipping into
> > the reserves becomes a system wide event.
>
> Shudder. That can just be a desaster for NUMA. Both performance wise
> and logic wise. One cpuset being low on memory should not affect
> applications in other cpusets.

Currently your system likely would have died here, so ending up with a 
reserve page temporarily on the wrong node is already an improvement. 

I agree that the reserve pool should be per-node in the end, but I do 
not think that serves the interest of simplifying the initial patch 
set.  How about a numa performance patch that adds onto the end of 
Peter's series?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
