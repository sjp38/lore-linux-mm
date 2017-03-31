Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFEE6B0397
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:50:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 81so67068075pgh.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 20:50:00 -0700 (PDT)
Received: from out0-193.mail.aliyun.com (out0-193.mail.aliyun.com. [140.205.0.193])
        by mx.google.com with ESMTP id j16si3751445pfk.353.2017.03.30.20.49.59
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 20:49:59 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170330115454.32154-1-mhocko@kernel.org> <20170330115454.32154-4-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-4-mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm: remove return value from init_currently_empty_zone
Date: Fri, 31 Mar 2017 11:49:49 +0800
Message-ID: <04ad01d2a9d1$d99b0540$8cd10fc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Reza Arbab' <arbab@linux.vnet.ibm.com>, 'Yasuaki Ishimatsu' <yasu.isimatu@gmail.com>, 'Tang Chen' <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, 'Kani Toshimitsu' <toshi.kani@hpe.com>, slaoub@gmail.com, 'Joonsoo Kim' <js1304@gmail.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Zhang Zhen' <zhenzhang.zhang@huawei.com>, 'David Rientjes' <rientjes@google.com>, 'Daniel Kiper' <daniel.kiper@oracle.com>, 'Igor Mammedov' <imammedo@redhat.com>, 'Vitaly Kuznetsov' <vkuznets@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

On March 30, 2017 7:55 PM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> init_currently_empty_zone doesn't have any error to return yet it is
> still an int and callers try to be defensive and try to handle potential
> error. Remove this nonsense and simplify all callers.
> 
It is already cut off in 1/6 in this series?

<snip>

> -/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
> - * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
> -static int __ref ensure_zone_is_initialized(struct zone *zone,
> +static void __ref ensure_zone_is_initialized(struct zone *zone,
>  			unsigned long start_pfn, unsigned long num_pages)
>  {
> -	if (zone_is_empty(zone))
> -		return init_currently_empty_zone(zone, start_pfn, num_pages);
> -
> -	return 0;
> +	if (!zone_is_empty(zone))
> +		init_currently_empty_zone(zone, start_pfn, num_pages);
>  }
Semantic change added?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
