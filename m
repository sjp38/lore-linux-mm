Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id BA37F6B003B
	for <linux-mm@kvack.org>; Sat, 25 May 2013 21:44:03 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id p14so3916470vbm.14
        for <linux-mm@kvack.org>; Sat, 25 May 2013 18:44:02 -0700 (PDT)
Message-ID: <51A168E0.3020305@gmail.com>
Date: Sat, 25 May 2013 21:44:00 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com> <51A16268.4000401@gmail.com> <51a1642b.077c320a.3884.161cSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <51a1642b.077c320a.3884.161cSMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

(5/25/13 9:23 PM), Wanpeng Li wrote:
> Hi KOSAKI,
> On Sat, May 25, 2013 at 09:16:24PM -0400, KOSAKI Motohiro wrote:
>>> ---
>>>  mm/page_alloc.c | 2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 98cbdf6..23b921f 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -6140,6 +6140,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>>  		list_del(&page->lru);
>>>  		rmv_page_order(page);
>>>  		zone->free_area[order].nr_free--;
>>> +		if (PageHighMem(page))
>>> +			totalhigh_pages -= 1 << order;
>>>  		for (i = 0; i < (1 << order); i++)
>>>  			SetPageReserved((page+i));
>>>  		pfn += (1 << order);
>>
>> memory hotplug don't support 32bit since it was born, at least, when the system has highmem. 
>> Why can't we disable memory hotremove when 32bit at compile time?
> 
> Here is logic memory remove instead of ACPI based memory remove. ;-)

I know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
