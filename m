Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A748A6B04C9
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 03:14:29 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 6-v6so2625847edz.10
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 00:14:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s28-v6si190159edd.159.2018.11.07.00.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 00:14:28 -0800 (PST)
Date: Wed, 7 Nov 2018 09:14:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
Message-ID: <20181107081426.GW27423@dhcp22.suse.cz>
References: <20181106095524.14629-1-mhocko@kernel.org>
 <20181106203518.GC9042@350D>
 <20181107073548.GU27423@dhcp22.suse.cz>
 <1541577326.3089.2.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541577326.3089.2.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-18 08:55:26, osalvador wrote:
> On Wed, 2018-11-07 at 08:35 +0100, Michal Hocko wrote:
> > On Wed 07-11-18 07:35:18, Balbir Singh wrote:
> > > The check seems to be quite aggressive and in a loop that iterates
> > > pages, but has nothing to do with the page, did you mean to make
> > > the check
> > > 
> > > zone_idx(page_zone(page)) == ZONE_MOVABLE
> > 
> > Does it make any difference? Can we actually encounter a page from a
> > different zone here?
> 
> AFAIK, test_pages_in_a_zone() called from offline_pages() should ensure
> that the range belongs to a unique zone, so we should not encounter
> pages from other zones there, right?

Yes that is the case for memory hotplug. We do assume a single zone at
set_migratetype_isolate where we take the zone->lock. If the
contig_alloc can span multiple zones then it should check for similar.
-- 
Michal Hocko
SUSE Labs
