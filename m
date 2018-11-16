Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC32B6B0973
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 07:29:26 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id z13-v6so15148280pgv.18
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:29:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j29si29377099pgm.554.2018.11.16.04.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 04:29:25 -0800 (PST)
Message-ID: <1542371346.3020.16.camel@suse.de>
Subject: Re: [PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
From: osalvador <osalvador@suse.de>
Date: Fri, 16 Nov 2018 13:29:06 +0100
In-Reply-To: <20181116112218.GH14706@dhcp22.suse.cz>
References: <20181116083020.20260-1-mhocko@kernel.org>
	 <20181116083020.20260-6-mhocko@kernel.org>
	 <1542365221.3020.9.camel@suse.de> <20181116112218.GH14706@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 2018-11-16 at 12:22 +0100, Michal Hocko wrote:
> On Fri 16-11-18 11:47:01, osalvador wrote:
> > On Fri, 2018-11-16 at 09:30 +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index a919ba5cb3c8..ec2c7916dc2d 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone,
> > > struct page *page, int count,
> > >  	return false;
> > >  unmovable:
> > >  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> > > +	dump_page(pfn_to_page(pfn+iter), "unmovable page");
> > 
> > Would not be enough to just do:
> > 
> > dump_page(page, "unmovable page".
> > 
> > Unless I am missing something, page should already have the
> > right pfn?
> 
> What if pfn_valid_within fails? You could have a pointer to the
> previous
> page.

Sorry, I missed that, you are right.

> > 
> > <---
> > unsigned long check = pfn + iter;
> > page = pfn_to_page(check);
> > --->
> > 
> > The rest looks good to me
> > 
> > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 
> Thanks!
> 
