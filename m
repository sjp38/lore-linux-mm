Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id AC4456B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:42:40 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on dirty pages encountered, not priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-7-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:42:39 -0700
In-Reply-To: <1363525456-10448-7-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Sun, 17 Mar 2013 13:04:12 +0000")
Message-ID: <m2620qjdeo.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:

> @@ -495,6 +495,9 @@ typedef enum {
>  	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>  					 * a congested BDI
>  					 */
> +	ZONE_DIRTY,			/* reclaim scanning has recently found
> +					 * many dirty file pages
> +					 */

Needs a better name. ZONE_DIRTY_CONGESTED ? 

> +	 * currently being written then flag that kswapd should start
> +	 * writing back pages.
> +	 */
> +	if (global_reclaim(sc) && nr_dirty &&
> +			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
> +		zone_set_flag(zone, ZONE_DIRTY);
> +
>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,

I suppose you want to trace the dirty case here too.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
