Date: Tue, 8 Apr 2008 14:05:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/18] SLUB: Trigger defragmentation from memory reclaim
In-Reply-To: <20080407231137.6e3a38cd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081403220.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230227.768964864@sgi.com>
 <20080407231137.6e3a38cd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> > + * zone is the zone for which we are shrinking the slabs. If the intent
> > + * is to do a global shrink then zone may be NULL. Specification of a
> > + * zone is currently only used to limit slab defragmentation to a NUMA node.
> > + * The performace of shrink_slab would be better (in particular under NUMA)
> > + * if it could be targeted as a whole to the zone that is under memory
> > + * pressure but the VFS infrastructure does not allow that at the present
> > + * time.
> 
> Surely this will falsely trigger the ->next_defrag logic?

slab reclaim is run rarely so I thought that these races do not matter 
much.

We could put that next_defrag logic into the per node structure 
and protect it by taking the partial list lock if we wanted to be race 
safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
