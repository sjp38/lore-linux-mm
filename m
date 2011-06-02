Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 96AAB6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 06:38:25 -0400 (EDT)
Date: Thu, 2 Jun 2011 11:38:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: compaction: fix special case -1 order checks
Message-ID: <20110602103820.GE7306@suse.de>
References: <20110530123831.GG20166@tiehlicka.suse.cz>
 <20110530151633.GB1505@barrios-laptop>
 <20110530152450.GH20166@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110530152450.GH20166@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, May 30, 2011 at 05:24:50PM +0200, Michal Hocko wrote:
> <SNIP>
> mm: compaction: fix special case -1 order checks
> 
> 56de7263 (mm: compaction: direct compact when a high-order allocation
> fails) introduced a check for cc->order == -1 in compact_finished. We
> should continue compacting in that case because the request came from
> userspace and there is no particular order to compact for.
> Similar check has been added by 82478fb7 (mm: compaction:
> prevent division-by-zero during user-requested compaction) for
> compaction_suitable.
> 
> The check is, however, done after zone_watermark_ok which uses order as
> a right hand argument for shifts. Not only watermark check is pointless
> if we can break out without it but it also uses 1 << -1 which is not
> well defined (at least from C standard). Let's move the -1 check above
> zone_watermark_ok.
> 
> [Minchan Kim <minchan.kim@gmail.com> - caught compaction_suitable]
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
