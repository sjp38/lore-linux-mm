Date: Thu, 8 Nov 2007 13:27:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/23] Slab defragmentation V6
In-Reply-To: <1194555495.5295.27.camel@localhost>
Message-ID: <Pine.LNX.4.64.0711081327120.10596@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com>  <1194535612.6214.9.camel@localhost>
  <Pine.LNX.4.64.0711081103360.8954@schroedinger.engr.sgi.com>
 <1194555495.5295.27.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Lee Schermerhorn wrote:

> > ZONE_MOVABLE also contains mlocked pages that are also not reclaimable. 
> > The question is at what level would it be possible to make them MOVABLE? 
> > It may take some improvements to the kick() methods to make eviction more 
> > reliable. Allowing the moving of objects in the kick() methods will 
> > likely get usthere.
> 
> Christoph:  Although mlocked pages are not reclaimable, they ARE
> migratable.  You fixed that a long time ago.  [And I just verified with
> memtoy.]  Doesn't this make them "movable"?

I know. They are movable but not reclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
