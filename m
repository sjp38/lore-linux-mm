Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB9606B03A5
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 08:22:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l2so4477736wml.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:22:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r129si23859694wmr.28.2016.12.21.05.22.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 05:22:03 -0800 (PST)
Date: Wed, 21 Dec 2016 14:22:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161221132200.GK31118@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
 <20161219152156.GC5175@dhcp22.suse.cz>
 <20161220164823.GB13224@vultr.guest>
 <20161221075115.GE16502@dhcp22.suse.cz>
 <20161221131332.GB23096@vultr.guest>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221131332.GB23096@vultr.guest>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-12-16 13:13:32, Wei Yang wrote:
> On Wed, Dec 21, 2016 at 08:51:16AM +0100, Michal Hocko wrote:
> >On Tue 20-12-16 16:48:23, Wei Yang wrote:
> >> On Mon, Dec 19, 2016 at 04:21:57PM +0100, Michal Hocko wrote:
> >> >On Sun 18-12-16 14:47:50, Wei Yang wrote:
> >> >> memblock_reserve() may fail in case there is not enough regions.
> >> >
> >> >Have you seen this happenning in the real setups or this is a by-review
> >> >driven change?
> >> 
> >> This is a by-review driven change.
> >> 
> >> >[...]
> >> >>  again:
> >> >>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
> >> >>  					    nid, flags);
> >> >> -	if (alloc)
> >> >> +	if (alloc && !memblock_reserve(alloc, size))
> >> >>  		goto done;
> >
> >So how exactly does the reserve fail when memblock_find_in_range_node
> >found a suitable range for the given size?
> >
> 
> Even memblock_find_in_range_node() gets a suitable range, memblock_reserve()
> still could fail. And the case just happens when memblock can't resize.
> memblock_reserve() reserve a range by adding a range to memblock.reserved. In
> case the memblock.reserved is full and can't resize, this fails.

Sorry for being dense but what does it mean that the reserved will get
full? Also how probable is such a situation? Is it even real? In other
words does this fix a real or only a theoretical problem?

Anyway this all should be part of the changelog.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
