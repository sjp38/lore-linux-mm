Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32E616B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 07:01:04 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id g67so234964370ybi.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:01:04 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id c68si13480135qke.294.2016.08.22.04.01.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 04:01:03 -0700 (PDT)
Subject: Re: [RFC PATCH v2 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
 <1471834603-27053-2-git-send-email-xieyisheng1@huawei.com>
 <20160822080101.GE13596@dhcp22.suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <32ed1cea-df4b-a170-2d6f-0a4e05ee8405@huawei.com>
Date: Mon, 22 Aug 2016 18:37:58 +0800
MIME-Version: 1.0
In-Reply-To: <20160822080101.GE13596@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 2016/8/22 16:01, Michal Hocko wrote:
> On Mon 22-08-16 10:56:42, Xie Yisheng wrote:
>>  
>> +config ARCH_HAS_GIGANTIC_PAGE
>> +	depends on HUGETLB_PAGE
>> +	bool
>> +
> 
> but is this really necessary? The code where we use
> ARCH_HAS_GIGANTIC_PAGE already depends on HUGETLB_PAGE.
> 
Hi Michal,
Thank you for your reply.
That right, it's no need to depends on HUGETLB_PAGE here.

I will send v3 soon.

Thanks
Xie Yisheng
> Other than that looks good to me and a nice simplification.
> 
>>  source "fs/configfs/Kconfig"
>>  source "fs/efivarfs/Kconfig"
>>  
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 87e11d8..8488dcc 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1022,7 +1022,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>>  		nr_nodes--)
>>  
>> -#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
>> +#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) && \
>>  	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>>  	defined(CONFIG_CMA))
>>  static void destroy_compound_gigantic_page(struct page *page,
>> -- 
>> 1.7.12.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
