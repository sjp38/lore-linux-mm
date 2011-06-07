Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B76A6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 12:26:59 -0400 (EDT)
Date: Tue, 7 Jun 2011 17:26:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: compaction: Abort compaction if too many pages
 are isolated and caller is asynchronous
Message-ID: <20110607162654.GN5247@suse.de>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-5-git-send-email-mgorman@suse.de>
 <20110607155029.GL1686@barrios-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110607155029.GL1686@barrios-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 08, 2011 at 12:50:29AM +0900, Minchan Kim wrote:
> > <SNIP>
> > @@ -533,8 +544,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  		unsigned long nr_migrate, nr_remaining;
> >  		int err;
> >  
> > -		if (!isolate_migratepages(zone, cc))
> > +		switch (isolate_migratepages(zone, cc)) {
> > +		case ISOLATE_ABORT:
> 
> In this case, you change old behavior slightly.
> In old case, we return COMPACT_PARTIAL to cancel migration.
> But this patch makes to return COMPACT_SUCCESS.
> At present, return value of compact_zone is only used by __alloc_pages_direct_compact
> and it only consider COMPACT_SKIPPED so it would be not a problem.
> But I think it would be better to return COMPACT_PARTIAL instead of COMPACT_CONTINUE
> for consistency with compact_finished and right semantic for the future user of compact_zone.
> 

Agreed. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
