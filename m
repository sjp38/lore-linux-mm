Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 9F6ED6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 05:53:32 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:53:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per
 priority
Message-ID: <20130411095325.GI3710@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-9-git-send-email-mgorman@suse.de>
 <20130409065325.GA4411@lge.com>
 <20130409111358.GB2002@suse.de>
 <20130410010734.GR17758@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130410010734.GR17758@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

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

Yes, 100% agreed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
