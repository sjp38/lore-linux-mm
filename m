Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 031538E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 05:23:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so755809edb.1
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 02:23:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3-v6si3295101ejb.316.2019.01.23.02.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 02:23:17 -0800 (PST)
Date: Wed, 23 Jan 2019 11:22:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-ID: <20190123102242.GT4087@dhcp22.suse.cz>
References: <20190122154407.18417-1-osalvador@suse.de>
 <20190123094717.GQ4087@dhcp22.suse.cz>
 <20190123101838.qxsapn4dhcergs6t@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123101838.qxsapn4dhcergs6t@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com

On Wed 23-01-19 11:18:42, Oscar Salvador wrote:
> On Wed, Jan 23, 2019 at 10:47:17AM +0100, Michal Hocko wrote:
> > So this should be probably folded into the above patch as it is
> > incomplete unless I am missing something.
> 
> Well, they are triggered from different paths.
> The former error was triggered in:
> 
> removable_show
>  is_mem_section_removable
>   is_pageblock_removable_nolock
>    has_unmovable_pages
> 
> while this one is triggered when actually doing the offline operation

But it would trigger from the offline path as well, no?

> __offline_pages
>  scan_movable_pages
>  
> But I do agree that one without the other is not really useful, an incomplete.
> The truth is that I did not spot this one when fixing [1] because I did not
> really try to offline the memblock back then, so my fault.

I should have noticed that during the review but those paths are really
far away from each other so this is hard to spot indeed

> While I agree that the best approach would be to fold this one into [1],
> I am not sure if it is too late for that as it seems that [1] was already
> released into mainline, and moreover to stable.

OK, I wasn't aware of that. Then my suggestion is clearly moot.

> I guess I will have Andrew decide what is the best way to carry on here.
> 
> [1] https://patchwork.kernel.org/patch/10739963/
> 
> > 
> > > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > 
> > Other than that the change looks good to me.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> -- 
> Oscar Salvador
> SUSE L3

-- 
Michal Hocko
SUSE Labs
