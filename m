Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E94E6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 03:07:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 34so70504835pgx.6
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 00:07:04 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id r21si4262887pgo.226.2017.03.31.00.07.02
        for <linux-mm@kvack.org>;
        Fri, 31 Mar 2017 00:07:03 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170330115454.32154-1-mhocko@kernel.org> <20170330115454.32154-4-mhocko@kernel.org> <04ad01d2a9d1$d99b0540$8cd10fc0$@alibaba-inc.com> <20170331064901.GC27098@dhcp22.suse.cz>
In-Reply-To: <20170331064901.GC27098@dhcp22.suse.cz>
Subject: Re: [PATCH 3/6] mm: remove return value from init_currently_empty_zone
Date: Fri, 31 Mar 2017 15:06:41 +0800
Message-ID: <04e301d2a9ed$5a0620a0$0e1261e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Zhang Zhen' <zhenzhang.zhang@huawei.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>

On March 31, 2017 2:49 PM Michal Hocko wrote: 
> On Fri 31-03-17 11:49:49, Hillf Danton wrote:
> [...]
> > > -/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
> > > - * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
> > > -static int __ref ensure_zone_is_initialized(struct zone *zone,
> > > +static void __ref ensure_zone_is_initialized(struct zone *zone,
> > >  			unsigned long start_pfn, unsigned long num_pages)
> > >  {
> > > -	if (zone_is_empty(zone))
> > > -		return init_currently_empty_zone(zone, start_pfn, num_pages);
> > > -
> > > -	return 0;
> > > +	if (!zone_is_empty(zone))
> > > +		init_currently_empty_zone(zone, start_pfn, num_pages);
> > >  }
> > Semantic change added?
> 
> could you be more specific?

Well, I'm wondering why you are trying to initiate a nonempty zone.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
