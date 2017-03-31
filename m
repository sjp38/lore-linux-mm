Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7859A6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 03:18:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w96so14579233wrb.13
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 00:18:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t74si2186090wmd.121.2017.03.31.00.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 00:18:07 -0700 (PDT)
Date: Fri, 31 Mar 2017 09:18:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm: remove return value from
 init_currently_empty_zone
Message-ID: <20170331071804.GE27098@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-4-mhocko@kernel.org>
 <04ad01d2a9d1$d99b0540$8cd10fc0$@alibaba-inc.com>
 <20170331064901.GC27098@dhcp22.suse.cz>
 <04e301d2a9ed$5a0620a0$0e1261e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04e301d2a9ed$5a0620a0$0e1261e0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Zhang Zhen' <zhenzhang.zhang@huawei.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 31-03-17 15:06:41, Hillf Danton wrote:
> On March 31, 2017 2:49 PM Michal Hocko wrote: 
> > On Fri 31-03-17 11:49:49, Hillf Danton wrote:
> > [...]
> > > > -/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
> > > > - * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
> > > > -static int __ref ensure_zone_is_initialized(struct zone *zone,
> > > > +static void __ref ensure_zone_is_initialized(struct zone *zone,
> > > >  			unsigned long start_pfn, unsigned long num_pages)
> > > >  {
> > > > -	if (zone_is_empty(zone))
> > > > -		return init_currently_empty_zone(zone, start_pfn, num_pages);
> > > > -
> > > > -	return 0;
> > > > +	if (!zone_is_empty(zone))
> > > > +		init_currently_empty_zone(zone, start_pfn, num_pages);
> > > >  }
> > > Semantic change added?
> > 
> > could you be more specific?
> 
> Well, I'm wondering why you are trying to initiate a nonempty zone.

Ups, another fuck up during the initial patch split up. Thanks for
catching that but it would be more helpful to be more specific during
the feedback. I am getting blind to the code I am staring for quite some
time so it was not obvious what you mean here.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
