Date: Tue, 8 Apr 2008 14:25:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
Message-Id: <20080408142505.4bfc7a4d.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com>
	<20080404230226.847485429@sgi.com>
	<20080407231129.3c044ba1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
	<20080408141135.de5a6350.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008 14:17:15 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 8 Apr 2008, Andrew Morton wrote:
> 
> > I know that.  It's still an arbitrary-to-the-point-of-uselessness hack.
> > 
> > Reclaim is clocked by scanning rates, allocation rates and disk speed.  Not
> > wall time.
> 
> Hmmmm... We could key it to the rate of free of objects that 
> shrink_slab() has been able to accomplish? We already check for != 0 
> there. The more are freed the more urgent to scan the partial lists for 
> reclaimable slabs.
> 

That's related to the scanning priority, isn't it?

It makes sense to pass the scan_control down into the shrinker callouts -
that has come up before.  That would provide access to the scanning
priority, as well as to anything else we want to toss in there in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
