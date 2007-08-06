Date: Mon, 6 Aug 2007 12:16:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 03/10] mm: tag reseve pages
In-Reply-To: <20070806121053.baed9691.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708061212550.7603@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.356795000@chello.nl>
 <Pine.LNX.4.64.0708061111390.25069@schroedinger.engr.sgi.com>
 <p73r6mglaog.fsf@bingen.suse.de> <Pine.LNX.4.64.0708061143050.3152@schroedinger.engr.sgi.com>
 <1186426079.11797.88.camel@lappy> <20070806185926.GB22499@one.firstfloor.org>
 <20070806121053.baed9691.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Andrew Morton wrote:

> Plus I don't think there are many flags left in the upper 32-bits.  ia64
> swooped in and gobbled lots of them, although it's not immediately clear
> how many were consumed.

IA64 uses one of these bits for the uncached allocator.  10 bits used for 
the node. Sparsemem may use some of the rest.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
