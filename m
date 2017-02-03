Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7C436B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 10:15:43 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so5593316wjc.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 07:15:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n132si2478548wmf.91.2017.02.03.07.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 07:15:42 -0800 (PST)
Date: Fri, 3 Feb 2017 16:15:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/7] mm: vmscan: move dirty pages out of the way until
 they're flushed
Message-ID: <20170203151532.GE19325@dhcp22.suse.cz>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
 <20170202191957.22872-7-hannes@cmpxchg.org>
 <006601d27df1$228a3940$679eabc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <006601d27df1$228a3940$679eabc0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Minchan Kim' <minchan.kim@gmail.com>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 03-02-17 15:42:55, Hillf Danton wrote:
> 
> On February 03, 2017 3:20 AM Johannes Weiner wrote: 
> > @@ -1063,7 +1063,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			    PageReclaim(page) &&
> >  			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
> >  				nr_immediate++;
> > -				goto keep_locked;
> > +				goto activate_locked;
> 
> Out of topic but relevant IMHO, I can't find where it is cleared by grepping:
> 
> $ grep -nr PGDAT_WRITEBACK  linux-4.9/mm
> linux-4.9/mm/vmscan.c:1019:	test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
> linux-4.9/mm/vmscan.c:1777:	set_bit(PGDAT_WRITEBACK, &pgdat->flags);

I would just get rid of this flag.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
