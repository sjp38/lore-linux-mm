Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CBB056B004D
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 06:40:54 -0400 (EDT)
Date: Tue, 10 Apr 2012 11:40:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: compaction: allow isolation of lower order buddy
 pages
Message-ID: <20120410104050.GF3789@suse.de>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
 <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, Apr 05, 2012 at 06:32:13PM +0200, Bartlomiej Zolnierkiewicz wrote:
> Allow lower order buddy pages in suitable_migration_target()
> so isolate_freepages() can isolate them as free pages during
> compaction_alloc() phase.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Nak.

This patch depends on patch 1 to scan every page in isolate_freepages()
and I explained why that is a problem already. That aside, a side-effect
of this is that movable pages can get migrated to MIGRATE_UNMOVABLE
and MIGRATE_RECLAIMABLE pageblocks. This will have a negative impact on
fragmentation avoidance. In your particular use-case it will slightly
increase allocation success rates early in the lifetime of the system at
the cost of degrading success rates later.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
