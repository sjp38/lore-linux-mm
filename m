Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CD23E6B01B1
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 21:56:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2O1urt3007483
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 10:56:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B965C45DE52
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 10:56:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 955DD45DE50
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 10:56:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D41E1DB804A
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 10:56:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FB841DB804B
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 10:56:53 +0900 (JST)
Date: Wed, 24 Mar 2010 10:53:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-Id: <20100324105311.2f41e82b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361003231847q1e4b7c7agdf82c4b2e920ada4@mail.gmail.com>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-8-git-send-email-mel@csn.ul.ie>
	<20100324100334.8d6f0739.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003231847q1e4b7c7agdf82c4b2e920ada4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 10:47:41 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 24, 2010 at 10:03 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 23 Mar 2010 12:25:42 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> This patch is the core of a mechanism which compacts memory in a zone by
> >> relocating movable pages towards the end of the zone.
> >>
> >> A single compaction run involves a migration scanner and a free scanner.
> >> Both scanners operate on pageblock-sized areas in the zone. The migration
> >> scanner starts at the bottom of the zone and searches for all movable pages
> >> within each area, isolating them onto a private list called migratelist.
> >> The free scanner starts at the top of the zone and searches for suitable
> >> areas and consumes the free pages within making them available for the
> >> migration scanner. The pages isolated for migration are then migrated to
> >> the newly isolated free pages.
> >>
> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >> Acked-by: Rik van Riel <riel@redhat.com>
> >> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >
> > I think lru_add_drain() or lru_add_drain_all() should be called somewhere
> > when we do __isolate_lru_page(). But it's (_all is) slow....
> >
> 
> migrate_prep does it.
> 
Thanks.

Hmm...then, lru_add_drain_all() is called at each (32page migrate) itelation.
Isn't it too slow to be called in such frequency ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
