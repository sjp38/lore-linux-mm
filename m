Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B18006B0037
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 14:45:37 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so3286364wiv.0
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 11:45:37 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dw1si7627996wib.88.2014.08.01.11.45.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 11:45:34 -0700 (PDT)
Date: Fri, 1 Aug 2014 14:45:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg, vmscan: Fix forced scan of anonymous pages
Message-ID: <20140801184525.GK9952@cmpxchg.org>
References: <1406807385-5168-1-git-send-email-jmarchan@redhat.com>
 <1406807385-5168-3-git-send-email-jmarchan@redhat.com>
 <20140731123026.GE13561@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140731123026.GE13561@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Thu, Jul 31, 2014 at 02:30:26PM +0200, Michal Hocko wrote:
> On Thu 31-07-14 13:49:45, Jerome Marchand wrote:
> > @@ -1950,8 +1950,11 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
> >  	 */
> >  	if (global_reclaim(sc)) {
> >  		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
> > +		unsigned long zonefile =
> > +			zone_page_state(zone, NR_LRU_BASE + LRU_ACTIVE_FILE) +
> > +			zone_page_state(zone, NR_LRU_BASE + LRU_INACTIVE_FILE);
> >  
> > -		if (unlikely(file + free <= high_wmark_pages(zone))) {
> > +		if (unlikely(zonefile + free <= high_wmark_pages(zone))) {
> >  			scan_balance = SCAN_ANON;
> >  			goto out;
> >  		}
> 
> You could move file and anon further down when we actually use them.

Agreed with that.  Can we merge this into the original patch?

---
