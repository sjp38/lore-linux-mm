Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 462536B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:47:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id um15so1222705pbc.28
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 09:47:29 -0700 (PDT)
Message-ID: <5140AD9B.1030509@gmail.com>
Date: Thu, 14 Mar 2013 00:47:23 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2, part2 08/10] mm/SPARC: use free_highmem_page() to
 free highmem pages into buddy system
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com> <1362902470-25787-9-git-send-email-jiang.liu@huawei.com> <20130312144215.1a92be86464bf82f81e3055e@linux-foundation.org>
In-Reply-To: <20130312144215.1a92be86464bf82f81e3055e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, sparclinux@vger.kernel.org

On 03/13/2013 05:42 AM, Andrew Morton wrote:
> On Sun, 10 Mar 2013 16:01:08 +0800 Jiang Liu <liuj97@gmail.com> wrote:
> 
>> Use helper function free_highmem_page() to free highmem pages into
>> the buddy system.
>>
>> ...
>>
>> --- a/arch/sparc/mm/init_32.c
>> +++ b/arch/sparc/mm/init_32.c
>> @@ -282,14 +282,8 @@ static void map_high_region(unsigned long start_pfn, unsigned long end_pfn)
>>  	printk("mapping high region %08lx - %08lx\n", start_pfn, end_pfn);
>>  #endif
>>  
>> -	for (tmp = start_pfn; tmp < end_pfn; tmp++) {
>> -		struct page *page = pfn_to_page(tmp);
>> -
>> -		ClearPageReserved(page);
>> -		init_page_count(page);
>> -		__free_page(page);
>> -		totalhigh_pages++;
>> -	}
>> +	for (tmp = start_pfn; tmp < end_pfn; tmp++)
>> +		free_higmem_page(pfn_to_page(tmp));
>>  }
> 
> This code isn't inside #ifdef CONFIG_HIGHMEM, but afaict that's OK
> because CONFIG_HIGHMEM=n isn't possible on sparc32.
> 
> This patch and one other mistyped "free_highmem_page".  I got lazy and
> edited those patches in-place.
> 
Hi Andrew,
	Great thanks for fixing them!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
