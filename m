Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC488D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 10:10:10 -0500 (EST)
Date: Thu, 10 Feb 2011 15:09:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] have smaps show transparent huge pages
Message-ID: <20110210150942.GL17873@csn.ul.ie>
References: <20110209195406.B9F23C9F@kernel> <20110209195413.6D3CB37F@kernel> <20110210112032.GG17873@csn.ul.ie> <1297350115.6737.14208.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1297350115.6737.14208.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, Feb 10, 2011 at 07:01:55AM -0800, Dave Hansen wrote:
> On Thu, 2011-02-10 at 11:20 +0000, Mel Gorman wrote:
> > > @@ -394,6 +395,7 @@ static int smaps_pte_range(pmd_t *pmd, u
> > >                       spin_lock(&walk->mm->page_table_lock);
> > >               } else {
> > >                       smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
> > > +                     mss->anonymous_thp += HPAGE_SIZE;
> > 
> > I should have thought of this for the previous patch but should this be
> > HPAGE_PMD_SIZE instead of HPAGE_SIZE? Right now, they are the same value
> > but they are not the same thing.
> 
> Probably.  There's also a nice BUG() in HPAGE_PMD_SIZE if the THP config
> option is off, which is an added bonus.
> 

Unless Andrea has an objection, I'd prefer to see HPAGE_PMD_SIZE.
Assuming that's ok;

Acked-by: Mel Gorman <mel@csn.ul.ie>

for the whole series.

Thanks Dave.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
