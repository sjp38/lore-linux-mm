Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2F068E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 13:13:55 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so1897355edm.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 10:13:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r23-v6si264987ejb.173.2019.01.08.10.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 10:13:54 -0800 (PST)
Date: Tue, 8 Jan 2019 19:13:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
Message-ID: <20190108181352.GI31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Tue 08-01-19 09:56:09, Alexander Duyck wrote:
> On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
[...]
> >  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  			void *arg)
> >  {
> > -	unsigned long i;
> >  	unsigned long onlined_pages = *(unsigned long *)arg;
> > -	struct page *page;
> >  
> >  	if (PageReserved(pfn_to_page(start_pfn)))
> > -		for (i = 0; i < nr_pages; i++) {
> > -			page = pfn_to_page(start_pfn + i);
> > -			(*online_page_callback)(page);
> > -			onlined_pages++;
> > -		}
> > +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
> 
> Shouldn't this be a "+=" instead of an "="? It seems like you are going
> to lose your count otherwise.

You are right of course. I should have noticed during the review.
Thanks!
-- 
Michal Hocko
SUSE Labs
