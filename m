Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A96BD6B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 01:25:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c81so3300014wmd.10
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 22:25:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h65si13538274wrh.371.2017.06.26.22.25.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 22:25:37 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:25:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: remove an unused variable in
 move_pfn_range_to_zone()
Message-ID: <20170627052535.GB28072@dhcp22.suse.cz>
References: <20170626231928.54565-1-richard.weiyang@gmail.com>
 <6a58b706-f409-b81f-4859-a6323bce1758@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a58b706-f409-b81f-4859-a6323bce1758@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 27-06-17 10:26:38, Anshuman Khandual wrote:
> On 06/27/2017 04:49 AM, Wei Yang wrote:
> > There is an unused variable in move_pfn_range_to_zone().
> > 
> > This patch just removes it.
> > 
> > Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> > ---
> >  mm/memory_hotplug.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 514014dde16b..16167c92bbf1 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -899,7 +899,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
> >  	struct pglist_data *pgdat = zone->zone_pgdat;
> >  	int nid = pgdat->node_id;
> >  	unsigned long flags;
> > -	unsigned long i;
> >  
> >  	if (zone_is_empty(zone))
> >  		init_currently_empty_zone(zone, start_pfn, nr_pages);
> 
> We have this down in the function. IIRC I had checked out tag
> mmotm-2017-06-16-13-59 where I am looking out for this function.

It's a follow up for
mm-memory_hotplug-do-not-associate-hotadded-memory-to-zones-until-online-fix-2.patch
in mmotm-2017-06-23-15-03

> 
> for (i = 0; i < nr_pages; i++) {
> 	unsigned long pfn = start_pfn + i;
> 	set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
> }
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
