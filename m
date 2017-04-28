Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38AC16B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 04:36:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k57so5195678wrk.6
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:36:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d29si2322941wmi.22.2017.04.28.01.36.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 01:36:49 -0700 (PDT)
Date: Fri, 28 Apr 2017 10:36:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Generic approach to customizable zones - was: Re: [PATCH v7 0/7]
 Introduce ZONE_CMA
Message-ID: <20170428083625.GG8143@dhcp22.suse.cz>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <d3c0d01c-ef3f-56f8-2701-a32f8be2d13b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3c0d01c-ef3f-56f8-2701-a32f8be2d13b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

I didn't read this thoughly yet because I will be travelling shortly but
this point alone just made ask, because it seems there is some
misunderstanding

On Fri 28-04-17 11:04:27, Igor Stoppa wrote:
[...]
> * if one is happy to have a 64bits type, allow for as many zones as
>   it's possible to fit, or anyway more than what is possible with
>   the 32 bit mask.

zones are currently placed in struct page::flags. And that already is
64b size on 64b arches. And we do not really have any room spare there.
We encode page flags, zone id, numa_nid/sparse section_nr there. How can
you add more without enlarging the struct page itself or using external
means to store the same information (page_ext comes to mind)? Even if
the later would be possible then note thatpage_zone() is used in many
performance sensitive paths and making it perform well with special
casing would be far from trivial.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
