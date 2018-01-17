Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8565628029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:15:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w141so4055345wme.1
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:15:00 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id j12si3684083wmc.215.2018.01.17.04.14.59
        for <linux-mm@kvack.org>;
        Wed, 17 Jan 2018 04:14:59 -0800 (PST)
Date: Wed, 17 Jan 2018 13:14:58 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2] mm/page_owner: Clean up init_pages_in_zone()
Message-ID: <20180117121458.GA32653@techadventures.net>
References: <20180110084355.GA22822@techadventures.net>
 <8395025d-90fd-7341-09b7-115ff131f6ac@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8395025d-90fd-7341-09b7-115ff131f6ac@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.com, akpm@linux-foundation.org

On Wed, Jan 17, 2018 at 11:02:24AM +0100, Vlastimil Babka wrote:
> On 01/10/2018 09:43 AM, Oscar Salvador wrote:
> > This patch removes two redundant assignments in init_pages_in_zone function.
> > 
> > Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> A nitpick below.
> 
> > ---
> >  mm/page_owner.c | 7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/page_owner.c b/mm/page_owner.c
> > index 69f83fc763bb..b361781e5ab6 100644
> > --- a/mm/page_owner.c
> > +++ b/mm/page_owner.c
> > @@ -528,14 +528,11 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
> >  
> >  static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
> >  {
> > -	struct page *page;
> > -	struct page_ext *page_ext;
> >  	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
> 
> block_end_pfn declaration could be moved to the outer for loop
> 
> >  	unsigned long end_pfn = pfn + zone->spanned_pages;
> 
> While here, I would use zone_end_pfn() on the line above.
> 
> >  	unsigned long count = 0;
> >  
> >  	/* Scan block by block. First and last block may be incomplete */
> 
> Now the comment is stray, I would just remove it too.

Hi Vlastimil, thanks for the fixes.
I'll send v3 with your suggestions.

Thanks

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
