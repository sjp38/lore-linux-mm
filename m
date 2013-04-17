Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 00C6F6B007B
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:39:18 -0400 (EDT)
Message-ID: <516E517F.5000003@huawei.com>
Date: Wed, 17 Apr 2013 15:38:39 +0800
From: Yijing Wang <wangyijing@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix build warning about kernel_physical_mapping_remove()
References: <1366182958-21892-1-git-send-email-wangyijing@huawei.com> <20130417072214.GA25283@hacker.(null)>
In-Reply-To: <20130417072214.GA25283@hacker.(null)>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

On 2013/4/17 15:22, Wanpeng Li wrote:
> On Wed, Apr 17, 2013 at 03:15:58PM +0800, Yijing Wang wrote:
>> If CONFIG_MEMORY_HOTREMOVE is not set, a build warning about
>> "warning: a??kernel_physical_mapping_removea?? defined but not used"
>> report.
>>
> 
> This has already been fixed by Tang Chen. 
> http://marc.info/?l=linux-mm&m=136614697618243&w=2

OK, I will drop this one, thanks!

> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>> Cc: Wen Congyang <wency@cn.fujitsu.com>
>> ---
>> arch/x86/mm/init_64.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> index 474e28f..dafdeb2 100644
>> --- a/arch/x86/mm/init_64.c
>> +++ b/arch/x86/mm/init_64.c
>> @@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
>> 	remove_pagetable(start, end, false);
>> }
>>
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> static void __meminit
>> kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>> {
>> @@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>> 	remove_pagetable(start, end, true);
>> }
>>
>> -#ifdef CONFIG_MEMORY_HOTREMOVE
>> int __ref arch_remove_memory(u64 start, u64 size)
>> {
>> 	unsigned long start_pfn = start >> PAGE_SHIFT;
>> -- 
>> 1.7.1
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> .
> 


-- 
Thanks!
Yijing

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
