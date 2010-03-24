Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0D66B01C9
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 06:57:30 -0400 (EDT)
Date: Wed, 24 Mar 2010 10:57:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100324105707.GC21147@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-8-git-send-email-mel@csn.ul.ie> <20100324100334.8d6f0739.kamezawa.hiroyu@jp.fujitsu.com> <28c262361003231847q1e4b7c7agdf82c4b2e920ada4@mail.gmail.com> <20100324105311.2f41e82b.kamezawa.hiroyu@jp.fujitsu.com> <28c262361003231910w27dbe52fqe02afad2b0238c9a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <28c262361003231910w27dbe52fqe02afad2b0238c9a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 11:10:14AM +0900, Minchan Kim wrote:
> On Wed, Mar 24, 2010 at 10:53 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 24 Mar 2010 10:47:41 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Wed, Mar 24, 2010 at 10:03 AM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Tue, 23 Mar 2010 12:25:42 +0000
> >> > Mel Gorman <mel@csn.ul.ie> wrote:
> >> >
> >> >> This patch is the core of a mechanism which compacts memory in a zone by
> >> >> relocating movable pages towards the end of the zone.
> >> >>
> >> >> A single compaction run involves a migration scanner and a free scanner.
> >> >> Both scanners operate on pageblock-sized areas in the zone. The migration
> >> >> scanner starts at the bottom of the zone and searches for all movable pages
> >> >> within each area, isolating them onto a private list called migratelist.
> >> >> The free scanner starts at the top of the zone and searches for suitable
> >> >> areas and consumes the free pages within making them available for the
> >> >> migration scanner. The pages isolated for migration are then migrated to
> >> >> the newly isolated free pages.
> >> >>
> >> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >> >> Acked-by: Rik van Riel <riel@redhat.com>
> >> >> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >> >
> >> > I think lru_add_drain() or lru_add_drain_all() should be called somewhere
> >> > when we do __isolate_lru_page(). But it's (_all is) slow....
> >> >
> >>
> >> migrate_prep does it.
> >>

Yep.

> > Thanks.
> >
> > Hmm...then, lru_add_drain_all() is called at each (32page migrate) itelation.
> > Isn't it too slow to be called in such frequency ?
> 
> I agree. We can move migrate_prep in compact_zone.
> 

Indeed we can. It's moved now.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
