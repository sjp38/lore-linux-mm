Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 271BB6B0027
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:39:02 -0400 (EDT)
Date: Thu, 21 Mar 2013 16:38:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130321153859.GQ6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <20130321145458.GM6094@dhcp22.suse.cz>
 <20130321152602.GI1878@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321152602.GI1878@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-03-13 15:26:02, Mel Gorman wrote:
> On Thu, Mar 21, 2013 at 03:54:58PM +0100, Michal Hocko wrote:
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/vmscan.c | 86 ++++++++++++++++++++++++++++++-------------------------------
> > >  1 file changed, 42 insertions(+), 44 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 182ff15..279d0c2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2625,8 +2625,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> > >  /*
> > >   * kswapd shrinks the zone by the number of pages required to reach
> > >   * the high watermark.
> > > + *
> > > + * Returns true if kswapd scanned at least the requested number of
> > > + * pages to reclaim.
> > 
> > Maybe move the comment about not rising priority in such case here to be
> > clear what the return value means. Without that the return value could
> > be misinterpreted that kswapd_shrink_zone succeeded in shrinking might
> > be not true.
> 
> I moved the comment.

Thanks

> > Or maybe even better, leave the void there and add bool *raise_priority
> > argument here so the decision and raise_priority are at the same place.
> > 
> 
> The priority is raised if kswapd failed to reclaim from any of the unbalanced
> zone. If raise_priority is moved inside kswapd_shrink_zone then it can
> only take one zone into account.

Right you are. I am blind.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
