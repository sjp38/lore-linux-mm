Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9D7D56B00EE
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 06:11:08 -0400 (EDT)
Date: Wed, 8 Jun 2011 12:11:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] mm: memory-failure: Fix isolated page count during
 memory failure
Message-ID: <20110608101105.GA9936@tiehlicka.suse.cz>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-4-git-send-email-mgorman@suse.de>
 <20110608100720.GF6742@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110608100720.GF6742@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed 08-06-11 12:07:20, Michal Hocko wrote:
> On Tue 07-06-11 16:07:04, Mel Gorman wrote:
> > From: Minchan Kim <minchan.kim@gmail.com>
> > 
> > From: Minchan Kim <minchan.kim@gmail.com>
> > 
> > Pages isolated for migration are accounted with the vmstat counters
> > NR_ISOLATE_[ANON|FILE]. Callers of migrate_pages() are expected to
> > increment these counters when pages are isolated from the LRU. Once
> > the pages have been migrated, they are put back on the LRU or freed
> > and the isolated count is decremented.
> 
> Aren't we missing this in compact_zone as well? AFAICS there is no
> accounting done after we isolate pages from LRU? Or am I missing
> something?

Scratch that. It was hidden in acct_isolated which is called from
isolate_migratepages.
It would be really strange if this was broken ;)

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
