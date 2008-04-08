Date: Tue, 8 Apr 2008 14:02:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
In-Reply-To: <20080407231129.3c044ba1.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230226.847485429@sgi.com>
 <20080407231129.3c044ba1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> >    Fragmentation is skipped if it was less than a tenth of a second since we
> >    last checked a slab cache. An unsuccessful defrag attempt pauses attempts
> >    for at least one second.
> 
> Can we not do this?  It's a really nasty hack.  Wall time has almost no
> correlation with reclaim and allocation activity.
> 
> If we really cannot think of anything smarter than just throttling then the
> decision regarding when to throttle and for how long should at least be
> driven by something which is vaguely correlated with the present/recent
> allocation/reclaim activity.

The reclaim interval increases to 1 second if slab reclaim was not 
succcessful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
