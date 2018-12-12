Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B41E58E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:47:04 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so8427683edm.18
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:47:04 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id n23si768099edt.94.2018.12.12.06.47.03
        for <linux-mm@kvack.org>;
        Wed, 12 Dec 2018 06:47:03 -0800 (PST)
Date: Wed, 12 Dec 2018 15:47:02 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: enable pcpu_drain with zone capability
Message-ID: <20181212144657.qpf27qhypda4e545@d104.suse.de>
References: <20181212002933.53337-1-richard.weiyang@gmail.com>
 <20181212142550.61686-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212142550.61686-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com

On Wed, Dec 12, 2018 at 10:25:50PM +0800, Wei Yang wrote:
> drain_all_pages is documented to drain per-cpu pages for a given zone (if
> non-NULL). The current implementation doesn't match the description though.
> It will drain all pcp pages for all zones that happen to have cached pages
> on the same cpu as the given zone. This will leave to premature pcp cache
> draining for zones that are not of an interest for the caller - e.g.
> compaction, hwpoison or memory offline.
> 
> This would force the page allocator to take locks and potential lock
> contention as a result.
> 
> There is no real reason for this sub-optimal implementnation. Replace
> per-cpu work item with a dedicated structure which contains a pointer to
> zone and pass it over to the worker. This will get the zone information all
> the way down to the worker function and do the right job.
> 
> [mhocko@suse.com: refactor the whole changelog]
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Looks to me

Reviewed-by: Oscar Salvador <osalvador@suse.de>

thanks

-- 
Oscar Salvador
SUSE L3
