Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2196A6B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:26:04 -0400 (EDT)
Date: Sun, 17 Mar 2013 15:25:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/10] mm: vmscan: Move logic from balance_pgdat() to
 kswapd_shrink_zone()
Message-ID: <20130317152556.GE2026@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-11-git-send-email-mgorman@suse.de>
 <m2sj3uhy85.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <m2sj3uhy85.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 07:55:54AM -0700, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > +
> > +	/*
> > +	 * We put equal pressure on every zone, unless one zone has way too
> > +	 * many pages free already. The "too many pages" is defined as the
> > +	 * high wmark plus a "gap" where the gap is either the low
> > +	 * watermark or 1% of the zone, whichever is smaller.
> > +	 */
> > +	balance_gap = min(low_wmark_pages(zone),
> > +		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> > +		KSWAPD_ZONE_BALANCE_GAP_RATIO);
> 
> Don't like those hard coded tunables. 1% of a 512GB node can be still
> quite a lot. Shouldn't the low watermark be enough?
> 

1% of 512G would be lot but in that case, it'll use the low watermark as
the balance gap.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
