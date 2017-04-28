Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BAF156B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 03:40:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b20so2691657wma.11
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 00:40:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s80si4871810wme.160.2017.04.28.00.40.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 00:40:33 -0700 (PDT)
Date: Fri, 28 Apr 2017 09:40:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
Message-ID: <20170428074028.GF8143@dhcp22.suse.cz>
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <20170427134158.GI4706@dhcp22.suse.cz>
 <f741d053-4303-5441-21bc-ec86bca1164c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f741d053-4303-5441-21bc-ec86bca1164c@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-04-17 17:06:05, Igor Stoppa wrote:
> 
> 
> On 27/04/17 16:41, Michal Hocko wrote:
> > On Wed 26-04-17 18:29:08, Igor Stoppa wrote:
> > [...]
> >> If you prefer to have this patch only as part of the larger patchset,
> >> I'm also fine with it.
> > 
> > I agree that the situation is not ideal. If a larger set of changes
> > would benefit from this change then it would clearly add arguments...
> 
> Ok, then I'll send it out as part of the larger RFC set.
> 
> 
> >> Also, if you could reply to [1], that would be greatly appreciated.
> > 
> > I will try to get to it but from a quick glance, yet-another-zone will
> > hit a lot of opposition...
> 
> The most basic questions, that I hope can be answered with Yes/No =) are:
> 
> - should a new zone be added after DMA32?
> 
> - should I try hard to keep the mask fitting a 32bit word - at least for
> hose who do not use the new zone - or is it ok to just stretch it to 64
> bits?

Do not add a new zone, really. What you seem to be looking for is an
allocator on top of the page/memblock allocator which does write
protection on top. I understand that you would like to avoid object
management duplication but I am not really sure how much you can re-use
what slab allocators do already, anyway. I will respond to the original
thread to not mix things together.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
