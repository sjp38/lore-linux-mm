Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3BF6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:49:15 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2678539pvc.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 07:49:10 -0700 (PDT)
Date: Mon, 13 Jun 2011 23:48:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v3 01/10] compaction: trivial clean up acct_isolated
Message-ID: <20110613144853.GA1414@barrios-desktop>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <71a79768ff8ef356db09493dbb5d6c390e176e0d.1307455422.git.minchan.kim@gmail.com>
 <20110612142257.GA24323@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110612142257.GA24323@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Jun 12, 2011 at 04:24:05PM +0200, Michal Hocko wrote:
> On Tue 07-06-11 23:38:14, Minchan Kim wrote:
> > acct_isolated of compaction uses page_lru_base_type which returns only
> > base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
> > In addtion, cc->nr_[anon|file] is used in only acct_isolated so it doesn't have
> > fields in conpact_control.
> > This patch removes fields from compact_control and makes clear function of
> > acct_issolated which counts the number of anon|file pages isolated.
> > 
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Sorry for the late reply. I have looked at the previous posting but

No problem. Thanks for the review, Michal.

> didn't have time to comment on it.
> 
> Yes, stack usage reduction makes sense and the function also looks more
> compact.
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
