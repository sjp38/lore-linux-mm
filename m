Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9F4D6B0505
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 08:06:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x1-v6so9169776edh.8
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 05:06:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j93-v6si537978edb.199.2018.11.07.05.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 05:06:56 -0800 (PST)
Date: Wed, 7 Nov 2018 14:06:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
Message-ID: <20181107130655.GE27423@dhcp22.suse.cz>
References: <20181106095524.14629-1-mhocko@kernel.org>
 <20181106203518.GC9042@350D>
 <20181107073548.GU27423@dhcp22.suse.cz>
 <20181107125324.GD9042@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107125324.GD9042@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-18 23:53:24, Balbir Singh wrote:
> On Wed, Nov 07, 2018 at 08:35:48AM +0100, Michal Hocko wrote:
> > On Wed 07-11-18 07:35:18, Balbir Singh wrote:
[...]
> > > The check seems to be quite aggressive and in a loop that iterates
> > > pages, but has nothing to do with the page, did you mean to make
> > > the check
> > > 
> > > zone_idx(page_zone(page)) == ZONE_MOVABLE
> > 
> > Does it make any difference? Can we actually encounter a page from a
> > different zone here?
> > 
> 
> Just to avoid page state related issues, do we want to go ahead
> with the migration if zone_idx(page_zone(page)) != ZONE_MOVABLE.

Could you be more specific what kind of state related issues you have in
mind?

> > > it also skips all checks for pinned pages and other checks
> > 
> > Yes, this is intentional and the comment tries to explain why. I wish we
> > could be add a more specific checks for movable pages - e.g. detect long
> > term pins that would prevent migration - but we do not have any facility
> > for that. Please note that the worst case of a false positive is a
> > repeated migration failure and user has a way to break out of migration
> > by a signal.
> >
> 
> Basically isolate_pages() will fail as opposed to hotplug failing upfront.
> The basic assertion this patch makes is that all ZONE_MOVABLE pages that
> are not reserved are hotpluggable.

Yes, that is correct.

-- 
Michal Hocko
SUSE Labs
