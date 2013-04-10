Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 43BC26B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:22:43 -0400 (EDT)
Date: Wed, 10 Apr 2013 14:23:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per
 priority
Message-ID: <20130410052325.GC5872@lge.com>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-9-git-send-email-mgorman@suse.de>
 <20130409065325.GA4411@lge.com>
 <20130409111358.GB2002@suse.de>
 <20130410010734.GR17758@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130410010734.GR17758@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Hello, Dave.

On Wed, Apr 10, 2013 at 11:07:34AM +1000, Dave Chinner wrote:
> On Tue, Apr 09, 2013 at 12:13:59PM +0100, Mel Gorman wrote:
> > On Tue, Apr 09, 2013 at 03:53:25PM +0900, Joonsoo Kim wrote:
> > 
> > > I think that outside of zone loop is better place to run shrink_slab(),
> > > because shrink_slab() is not directly related to a specific zone.
> > > 
> > 
> > This is true and has been the case for a long time. The slab shrinkers
> > are not zone aware and it is complicated by the fact that slab usage can
> > indirectly pin memory on other zones.
> ......
> > > And this is a question not related to this patch.
> > > Why nr_slab is used here to decide zone->all_unreclaimable?
> > 
> > Slab is not directly associated with a slab but as reclaiming slab can
> > free memory from unpredictable zones we do not consider a zone to be
> > fully unreclaimable until we cannot shrink slab any more.
> 
> This is something the numa aware shrinkers will greatly help with -
> instead of being a global shrink it becomes a
> node-the-zone-belongs-to shrink, and so....
> 
> > You may be thinking that this is extremely heavy handed and you're
> > right, it is.
> 
> ... it is much less heavy handed than the current code...
> 
> > > nr_slab is not directly related whether a specific zone is reclaimable
> > > or not, and, moreover, nr_slab is not directly related to number of
> > > reclaimed pages. It just say some objects in the system are freed.
> > > 
> > 
> > All true, it's the indirect relation between slab objects and the memory
> > that is freed when slab objects are reclaimed that has to be taken into
> > account.
> 
> Node awareness within the shrinker infrastructure and LRUs make the
> relationship much more direct ;)

Yes, I think so ;)

Thanks.

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
