Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D81836B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:39:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n129so66661289pga.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 20:39:18 -0700 (PDT)
Received: from out0-242.mail.aliyun.com (out0-242.mail.aliyun.com. [140.205.0.242])
        by mx.google.com with ESMTP id 2si3730979ple.237.2017.03.30.20.39.17
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 20:39:18 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170330115454.32154-1-mhocko@kernel.org> <20170330115454.32154-2-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-2-mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: get rid of zone_is_initialized
Date: Fri, 31 Mar 2017 11:39:07 +0800
Message-ID: <04a601d2a9d0$5ace0ab0$106a2010$@alibaba-inc.com>
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
> @@ -5535,9 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>  			zone_start_pfn, (zone_start_pfn + size));
> 
>  	zone_init_free_lists(zone);
> -	zone->initialized = 1;
> -
> -	return 0;
>  }
Nit: Add changes more than correct.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
