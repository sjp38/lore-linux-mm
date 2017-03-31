Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E299B6B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:50:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w96so14471854wrb.13
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:50:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si6809805wrd.272.2017.03.30.23.50.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 23:50:04 -0700 (PDT)
Date: Fri, 31 Mar 2017 08:50:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory
 to zones until online
Message-ID: <20170331065002.GD27098@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-6-mhocko@kernel.org>
 <04c901d2a9e6$91968a20$b4c39e60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04c901d2a9e6$91968a20$b4c39e60$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Dan Williams' <dan.j.williams@gmail.com>, 'Heiko Carstens' <heiko.carstens@de.ibm.com>, 'Lai Jiangshan' <laijs@cn.fujitsu.com>, 'Martin Schwidefsky' <schwidefsky@de.ibm.com>

On Fri 31-03-17 14:18:08, Hillf Danton wrote:
> 
> On March 30, 2017 7:55 PM Michal Hocko wrote:
> > 
> > +static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
> > +		unsigned long nr_pages)
> > +{
> > +	unsigned long old_end_pfn = zone_end_pfn(zone);
> > +
> > +	if (start_pfn < zone->zone_start_pfn)
> > +		zone->zone_start_pfn = start_pfn;
> > +
> > +	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
> > +}
> The implementation above implies zone can only go bigger.

yes, we do not shrink zones currently and I see no poit in doing that
right now.

> Can we resize zone with the given data?

Why couldn't we?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
