Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39EB26B2B29
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:29:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so4356546edb.1
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:29:25 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si7433949edb.125.2018.11.22.02.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:29:24 -0800 (PST)
Date: Thu, 22 Nov 2018 11:29:22 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181122102922.GE18011@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <20181122101557.pzq6ggiymn52gfqk@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122101557.pzq6ggiymn52gfqk@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 22-11-18 10:15:57, Wei Yang wrote:
> On Thu, Nov 22, 2018 at 06:12:41PM +0800, Wei Yang wrote:
> >During online_pages phase, pgdat->nr_zones will be updated in case this
> >zone is empty.
> >
> >Currently the online_pages phase is protected by the global lock
> >mem_hotplug_begin(), which ensures there is no contention during the
> >update of nr_zones. But this global lock introduces scalability issues.
> >
> >This patch is a preparation for removing the global lock during
> >online_pages phase. Also this patch changes the documentation of
> >node_size_lock to include the protectioin of nr_zones.

I would just add that the patch moves init_currently_empty_zone under
both zone_span_writelock and pgdat_resize_lock because both the pgdat
state is changed (nr_zones) and the zone's start_pfn

> >
> >Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 
> Missed this, if I am correct. :-)
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Yes, thank you.
-- 
Michal Hocko
SUSE Labs
