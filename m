Date: Mon, 6 Aug 2007 11:42:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <200708061121.50351.phillips@phunq.net>
Message-ID: <Pine.LNX.4.64.0708061141511.3152@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.107883000@chello.nl>
 <Pine.LNX.4.64.0708061108430.25069@schroedinger.engr.sgi.com>
 <200708061121.50351.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Daniel Phillips wrote:

> Currently your system likely would have died here, so ending up with a 
> reserve page temporarily on the wrong node is already an improvement. 

The system would have died? Why? The application in the cpuset that 
ran out of memory should have died not the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
