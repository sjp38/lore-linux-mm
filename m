Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9515E6B0946
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:22:22 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so18607141pfn.20
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:22:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10-v6si26777994plh.416.2018.11.16.03.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 03:22:21 -0800 (PST)
Date: Fri, 16 Nov 2018 12:22:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
Message-ID: <20181116112218.GH14706@dhcp22.suse.cz>
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-6-mhocko@kernel.org>
 <1542365221.3020.9.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542365221.3020.9.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 16-11-18 11:47:01, osalvador wrote:
> On Fri, 2018-11-16 at 09:30 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a919ba5cb3c8..ec2c7916dc2d 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone,
> > struct page *page, int count,
> >  	return false;
> >  unmovable:
> >  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> > +	dump_page(pfn_to_page(pfn+iter), "unmovable page");
> 
> Would not be enough to just do:
> 
> dump_page(page, "unmovable page".
> 
> Unless I am missing something, page should already have the
> right pfn?

What if pfn_valid_within fails? You could have a pointer to the previous
page.

> 
> <---
> unsigned long check = pfn + iter;
> page = pfn_to_page(check);
> --->
> 
> The rest looks good to me
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks!

-- 
Michal Hocko
SUSE Labs
