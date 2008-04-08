Date: Tue, 8 Apr 2008 14:11:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
Message-Id: <20080408141135.de5a6350.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com>
	<20080404230226.847485429@sgi.com>
	<20080407231129.3c044ba1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008 14:02:46 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 7 Apr 2008, Andrew Morton wrote:
> 
> > >    Fragmentation is skipped if it was less than a tenth of a second since we
> > >    last checked a slab cache. An unsuccessful defrag attempt pauses attempts
> > >    for at least one second.
> > 
> > Can we not do this?  It's a really nasty hack.  Wall time has almost no
> > correlation with reclaim and allocation activity.
> > 
> > If we really cannot think of anything smarter than just throttling then the
> > decision regarding when to throttle and for how long should at least be
> > driven by something which is vaguely correlated with the present/recent
> > allocation/reclaim activity.
> 
> The reclaim interval increases to 1 second if slab reclaim was not 
> succcessful.

I know that.  It's still an arbitrary-to-the-point-of-uselessness hack.

Reclaim is clocked by scanning rates, allocation rates and disk speed.  Not
wall time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
