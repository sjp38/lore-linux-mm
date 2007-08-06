Date: Mon, 6 Aug 2007 11:51:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <200708061148.43870.phillips@phunq.net>
Message-ID: <Pine.LNX.4.64.0708061150270.7603@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <200708061121.50351.phillips@phunq.net>
 <Pine.LNX.4.64.0708061141511.3152@schroedinger.engr.sgi.com>
 <200708061148.43870.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Daniel Phillips wrote:

> On Monday 06 August 2007 11:42, Christoph Lameter wrote:
> > On Mon, 6 Aug 2007, Daniel Phillips wrote:
> > > Currently your system likely would have died here, so ending up
> > > with a reserve page temporarily on the wrong node is already an
> > > improvement.
> >
> > The system would have died? Why?
> 
> Because a block device may have deadlocked here, leaving the system 
> unable to clean dirty memory, or unable to load executables over the 
> network for example.

So this is a locking problem that has not been taken care of?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
