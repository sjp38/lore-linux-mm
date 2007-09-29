Date: Sat, 29 Sep 2007 15:22:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: document tree_lock->zone.lock lockorder
Message-ID: <20070929132210.GF14159@wotan.suse.de>
References: <20070928155536.GC12538@wotan.suse.de> <20070928162039.9311c1e3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070928162039.9311c1e3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28, 2007 at 04:20:39PM -0700, Andrew Morton wrote:
> On Fri, 28 Sep 2007 17:55:36 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > If you won't take the patch to move allocation out from under tree_lock,
> 
> rofl@nick.  My memory of patches only extends back for the previous
> 10000 or so.  You'll need to put a tad more effort into telling us
> what you're referring to, sorry.

Just the patch to default the radix tree node allocation to use the
preload (which will be guaranteed to be full) before falling back to
doing atomic allocations under the tree_lock.

At the moment, it defaults to doing these atomic allocations first,
and leaves the preload alone, even though we've just done all the work
to allocate it under GFP_KERNEL.

Anyway.


> > please apply this update to lock ordering comments.
> 
> no probs, thanks.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
