Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 20BE76B0039
	for <linux-mm@kvack.org>; Sat, 25 May 2013 21:23:52 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 May 2013 11:13:17 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E2BE52CE804D
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:23:43 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q19Ljb24641538
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:09:22 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q1NfkU009875
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:23:42 +1000
Date: Sun, 26 May 2013 09:23:40 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Message-ID: <20130526012340.GA17787@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <51A16268.4000401@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51A16268.4000401@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi KOSAKI,
On Sat, May 25, 2013 at 09:16:24PM -0400, KOSAKI Motohiro wrote:
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
>memory hotplug don't support 32bit since it was born, at least, when the system has highmem. 
>Why can't we disable memory hotremove when 32bit at compile time?

Here is logic memory remove instead of ACPI based memory remove. ;-)

Regards,
Wanpeng Li 

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
