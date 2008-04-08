Date: Tue, 8 Apr 2008 14:47:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
In-Reply-To: <20080408142505.4bfc7a4d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230226.847485429@sgi.com>
 <20080407231129.3c044ba1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
 <20080408141135.de5a6350.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
 <20080408142505.4bfc7a4d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008, Andrew Morton wrote:

> > Hmmmm... We could key it to the rate of free of objects that 
> > shrink_slab() has been able to accomplish? We already check for != 0 
> > there. The more are freed the more urgent to scan the partial lists for 
> > reclaimable slabs.
> > 
> 
> That's related to the scanning priority, isn't it?

Not directly. The number of scanned pages (which depends on the scannig 
priority) is passed down and then shrink_slab does some magic to do a 
couple of passes.

> It makes sense to pass the scan_control down into the shrinker callouts -
> that has come up before.  That would provide access to the scanning
> priority, as well as to anything else we want to toss in there in the future.

The scanned pages etc is available at the point that kmem_cache_defrag() 
is called. We can add logic to shrink_slab to determine if a defrag scan 
is necessary. We likely need to add a field to the zone that gives us the 
objects freed since the last defrag scan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
