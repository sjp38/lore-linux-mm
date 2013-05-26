Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5B1926B00C4
	for <linux-mm@kvack.org>; Sun, 26 May 2013 10:30:03 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so5865355pbb.6
        for <linux-mm@kvack.org>; Sun, 26 May 2013 07:30:02 -0700 (PDT)
Message-ID: <51A21C63.4010606@gmail.com>
Date: Sun, 26 May 2013 22:29:55 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com> <51A16268.4000401@gmail.com>
In-Reply-To: <51A16268.4000401@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 05/26/2013 09:16 AM, KOSAKI Motohiro wrote:
>> ---
>>  mm/page_alloc.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 98cbdf6..23b921f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6140,6 +6140,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>  		list_del(&page->lru);
>>  		rmv_page_order(page);
>>  		zone->free_area[order].nr_free--;
>> +		if (PageHighMem(page))
>> +			totalhigh_pages -= 1 << order;
>>  		for (i = 0; i < (1 << order); i++)
>>  			SetPageReserved((page+i));
>>  		pfn += (1 << order);
> 
> memory hotplug don't support 32bit since it was born, at least, when the system has highmem. 
> Why can't we disable memory hotremove when 32bit at compile time?
Hi KOSAKI,
	Could you please help to give more information on the background
about why 32bit platforms with highmem can't support memory hot-removal?
We are trying to enable memory hot-removal on some 32bit platforms with
highmem, really appreciate your help here!
Thanks!
Gerry

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
