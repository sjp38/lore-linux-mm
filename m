Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3746B0261
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:15:19 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c9so5500767wrb.4
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:15:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k39si2769378edd.267.2017.12.01.09.15.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 09:15:18 -0800 (PST)
Date: Fri, 1 Dec 2017 18:15:17 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [patch 13/15] mm/page_owner: align with pageblock_nr pages
Message-ID: <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz>
References: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org>
 <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, zhongjiang@huawei.com

On Fri 01-12-17 17:58:28, Vlastimil Babka wrote:
> On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
> > From: zhong jiang <zhongjiang@huawei.com>
> > Subject: mm/page_owner: align with pageblock_nr pages
> > 
> > When pfn_valid(pfn) returns false, pfn should be aligned with
> > pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
> > because the skipped 2M may be valid pfn, as a result, early allocated
> > count will not be accurate.
> > 
> > Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
> > Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> The author never responded and Michal Hocko basically NAKed it in
> https://lkml.kernel.org/r/<20160812130727.GI3639@dhcp22.suse.cz>
> I think we should drop it.

Or extend the changelog to actually describe what kind of problem it
fixes and do an additional step to unigy
MAX_ORDER_NR_PAGES/pageblock_nr_pages
 
> > ---
> > 
> >  mm/page_owner.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -puN mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages mm/page_owner.c
> > --- a/mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages
> > +++ a/mm/page_owner.c
> > @@ -544,7 +544,7 @@ static void init_pages_in_zone(pg_data_t
> >  	 */
> >  	for (; pfn < end_pfn; ) {
> >  		if (!pfn_valid(pfn)) {
> > -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> > +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> >  			continue;
> >  		}
> >  
> > _
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
