Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7F716B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:18:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so67664485pge.7
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:18:20 -0700 (PDT)
Received: from out0-250.mail.aliyun.com (out0-250.mail.aliyun.com. [140.205.0.250])
        by mx.google.com with ESMTP id q87si4141872pfi.271.2017.03.30.23.18.19
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 23:18:20 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170330115454.32154-1-mhocko@kernel.org> <20170330115454.32154-6-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-6-mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory to zones until online
Date: Fri, 31 Mar 2017 14:18:08 +0800
Message-ID: <04c901d2a9e6$91968a20$b4c39e60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>, 'Dan Williams' <dan.j.williams@gmail.com>, 'Heiko Carstens' <heiko.carstens@de.ibm.com>, 'Lai Jiangshan' <laijs@cn.fujitsu.com>, 'Martin Schwidefsky' <schwidefsky@de.ibm.com>


On March 30, 2017 7:55 PM Michal Hocko wrote:
> 
> +static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
> +		unsigned long nr_pages)
> +{
> +	unsigned long old_end_pfn = zone_end_pfn(zone);
> +
> +	if (start_pfn < zone->zone_start_pfn)
> +		zone->zone_start_pfn = start_pfn;
> +
> +	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
> +}
The implementation above implies zone can only go bigger.
Can we resize zone with the given data?

btw,  this mail address, Zhang Zhen <zhenzhang.zhang@huawei.com> , is not reachable. 

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
