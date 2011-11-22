Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 795B86B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 04:51:48 -0500 (EST)
Date: Tue, 22 Nov 2011 09:51:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/8] mm: compaction: avoid overwork in migrate sync mode
Message-ID: <20111122095142.GI19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321732460-14155-6-git-send-email-aarcange@redhat.com>
 <4ECAC9C8.5040202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4ECAC9C8.5040202@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On Mon, Nov 21, 2011 at 04:59:36PM -0500, Rik van Riel wrote:
> On 11/19/2011 02:54 PM, Andrea Arcangeli wrote:
> >Add a lightweight sync migration (sync == 2) mode that avoids overwork
> >so more suitable to be used by compaction to provide lower latency but
> 
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -552,7 +552,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  		nr_migrate = cc->nr_migratepages;
> >  		err = migrate_pages(&cc->migratepages, compaction_alloc,
> >  				(unsigned long)cc, false,
> >-				cc->sync);
> >+				cc->sync ? 2 : 0);
> 
> Great idea, but it would be good if these numbers got
> a symbolic name so people trying to learn the code can
> figure it out a little easier.
> 

I took the bulk of this patch and gave them symbolic names when trying
to reconcile the two series. I didn't take all this patch such as
varying the number of passes because even if that turns out to be of
benefit, it should be a separate patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
