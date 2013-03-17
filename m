Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EAA486B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 10:55:55 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 10/10] mm: vmscan: Move logic from balance_pgdat() to kswapd_shrink_zone()
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
	<1363525456-10448-11-git-send-email-mgorman@suse.de>
Date: Sun, 17 Mar 2013 07:55:54 -0700
In-Reply-To: <1363525456-10448-11-git-send-email-mgorman@suse.de> (Mel
	Gorman's message of "Sun, 17 Mar 2013 13:04:16 +0000")
Message-ID: <m2sj3uhy85.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:

> +
> +	/*
> +	 * We put equal pressure on every zone, unless one zone has way too
> +	 * many pages free already. The "too many pages" is defined as the
> +	 * high wmark plus a "gap" where the gap is either the low
> +	 * watermark or 1% of the zone, whichever is smaller.
> +	 */
> +	balance_gap = min(low_wmark_pages(zone),
> +		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> +		KSWAPD_ZONE_BALANCE_GAP_RATIO);

Don't like those hard coded tunables. 1% of a 512GB node can be still
quite a lot. Shouldn't the low watermark be enough?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
