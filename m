Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98E7E6B0A8D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 12:07:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so546675edl.21
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 09:07:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6-v6si4769614edo.127.2018.11.16.09.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 09:07:56 -0800 (PST)
Date: Fri, 16 Nov 2018 18:07:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181116170755.GN14706@dhcp22.suse.cz>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
 <20181116095720.GE14706@dhcp22.suse.cz>
 <1542366304.3020.15.camel@suse.de>
 <20181116112603.GI14706@dhcp22.suse.cz>
 <20181116155828.strdglxqgqe4jqkr@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116155828.strdglxqgqe4jqkr@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-11-18 15:58:28, Wei Yang wrote:
> On Fri, Nov 16, 2018 at 12:26:03PM +0100, Michal Hocko wrote:
> >On Fri 16-11-18 12:05:04, osalvador wrote:
> >> On Fri, 2018-11-16 at 10:57 +0100, Michal Hocko wrote:
> >[...]
> >> > E.g. memory hotplug decreases both managed and present counters. I
> >> > am actually not sure that is 100% correct (put on my TODO list to
> >> > check). There is no consistency in that regards.
> >> 
> >> We can only offline non-reserved pages (so, managed pages).
> >
> >Yes
> >
> >> Since present pages holds reserved_pages + managed_pages, decreasing
> >> both should be fine unless I am mistaken.
> >
> >Well, present_pages is defined as "physical pages existing within the zone"
> >and those pages are still existing but they are offline. But as I've
> >said I have to think about it some more
> 
> I may not catch up with your discussions, while I'd like to share what I
> learnt.
> 
> online_pages()
>     online_pages_range()
>     zone->present_pages += onlined_pages;
> 
> __offline_pages()
>     adjust_managed_page_count()
>     zone->present_pages -= offlined_pages;
> 
> The two counters: present_pages & managed_pages would be adjusted during
> online/offline.
> 
> While I am not sure when *reserved_pages* would be adjusted. Will we add
> this hot-added memory into memblock.reserved? and allocate memory by
> memblock_alloc() after system bootup?

This is not really related to this patch. I have only mentioned the
memory hotplug as an example. I would rather focus on the change itself
so let's not get too off topic here.

-- 
Michal Hocko
SUSE Labs
