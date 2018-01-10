Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5A0E6B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 03:05:41 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o2so6634662wmf.2
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 00:05:41 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id v2si11810953wrd.379.2018.01.10.00.05.40
        for <linux-mm@kvack.org>;
        Wed, 10 Jan 2018 00:05:40 -0800 (PST)
Date: Wed, 10 Jan 2018 09:05:40 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm/page_owner.c Clean up init_pages_in_zone()
Message-ID: <20180110080540.GA22405@techadventures.net>
References: <20180109133303.GA11451@techadventures.net>
 <20180109171820.GN1732@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109171820.GN1732@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On Tue, Jan 09, 2018 at 06:18:20PM +0100, Michal Hocko wrote:
> On Tue 09-01-18 14:33:03, Oscar Salvador wrote:
> [...]
> > @@ -551,13 +548,11 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
> >  		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> >  		block_end_pfn = min(block_end_pfn, end_pfn);
> >  
> > -		page = pfn_to_page(pfn);
> > -
> >  		for (; pfn < block_end_pfn; pfn++) {
> >  			if (!pfn_valid_within(pfn))
> >  				continue;
> >  
> > -			page = pfn_to_page(pfn);
> > +			struct page *page = pfn_to_page(pfn);
> >  
> >  			if (page_zone(page) != zone)
> >  				continue;
> > @@ -580,7 +575,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
> >  			if (PageReserved(page))
> >  				continue;
> >  
> > -			page_ext = lookup_page_ext(page);
> > +			struct page_ext *page_ext = lookup_page_ext(page);
> >  			if (unlikely(!page_ext))
> >  				continue;
> 
> we do not interleave declarations with the code in the kernel. You can
> move those from the function scope to the loop scope and remove the
> pointless pfn and page initialization outside of the loop.

I will send a v2 fixing this.

Thanks!

Oscar Salvador

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
