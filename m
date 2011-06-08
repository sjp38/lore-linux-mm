Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEA4E6B0082
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 05:55:34 -0400 (EDT)
Date: Wed, 8 Jun 2011 11:55:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] mm: compaction: Abort compaction if too many pages
 are isolated and caller is asynchronous V2
Message-ID: <20110608095528.GE6742@tiehlicka.suse.cz>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-5-git-send-email-mgorman@suse.de>
 <20110607155029.GL1686@barrios-laptop>
 <20110607162711.GO5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607162711.GO5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue 07-06-11 17:27:11, Mel Gorman wrote:
> Changelog since V1
>   o Return COMPACT_PARTIAL when aborting due to too many isolated
>     pages. As pointed out by Minchan, this is better for consistency
> 
> Asynchronous compaction is used when promoting to huge pages. This is
> all very nice but if there are a number of processes in compacting
> memory, a large number of pages can be isolated. An "asynchronous"
> process can stall for long periods of time as a result with a user
> reporting that firefox can stall for 10s of seconds. This patch aborts
> asynchronous compaction if too many pages are isolated as it's better to
> fail a hugepage promotion than stall a process.
> 
> [minchan.kim@gmail.com: Return COMPACT_PARTIAL for abort]
> Reported-and-tested-by: Ury Stankevich <urykhy@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Michal Hocko <mhocko@suse.cz>
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
