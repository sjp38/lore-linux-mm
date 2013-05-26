Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 99A986B0087
	for <linux-mm@kvack.org>; Sun, 26 May 2013 05:03:55 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 May 2013 18:58:16 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 180D02BB0052
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:03:48 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q93dBk24051718
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:03:40 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q93kF9006077
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:03:47 +1000
Date: Sun, 26 May 2013 17:03:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/6] mm/memory_hotplug: remove
 memory_add_physaddr_to_nid
Message-ID: <20130526090344.GA27944@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369547921-24264-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130526085938.GD10651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130526085938.GD10651@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Sun, May 26, 2013 at 10:59:38AM +0200, Michal Hocko wrote:
>On Sun 26-05-13 13:58:37, Wanpeng Li wrote:
>> memory_add_physaddr_to_nid is not used any more, this patch remove it.
>
>git grep disagrees.
>git grep "= *\<memory_add_physaddr_to_nid\>" mmotm
>mmotm:drivers/acpi/acpi_memhotplug.c:                   node = memory_add_physaddr_to_nid(info->start_addr);
>mmotm:drivers/acpi/acpi_memhotplug.c:                   nid = memory_add_physaddr_to_nid(info->start_addr);
>mmotm:drivers/base/memory.c:            nid = memory_add_physaddr_to_nid(phys_addr);
>mmotm:drivers/xen/balloon.c:    nid = memory_add_physaddr_to_nid(hotplug_start_paddr);
>

Oh, sorry, I make a mistake here. 

>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  arch/x86/mm/numa.c | 15 ---------------
>>  1 file changed, 15 deletions(-)
>> 
>> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>> index a71c4e2..d470a54 100644
>> --- a/arch/x86/mm/numa.c
>> +++ b/arch/x86/mm/numa.c
>> @@ -803,18 +803,3 @@ const struct cpumask *cpumask_of_node(int node)
>>  EXPORT_SYMBOL(cpumask_of_node);
>>  
>>  #endif	/* !CONFIG_DEBUG_PER_CPU_MAPS */
>> -
>> -#ifdef CONFIG_MEMORY_HOTPLUG
>> -int memory_add_physaddr_to_nid(u64 start)
>> -{
>> -	struct numa_meminfo *mi = &numa_meminfo;
>> -	int nid = mi->blk[0].nid;
>> -	int i;
>> -
>> -	for (i = 0; i < mi->nr_blks; i++)
>> -		if (mi->blk[i].start <= start && mi->blk[i].end > start)
>> -			nid = mi->blk[i].nid;
>> -	return nid;
>> -}
>> -EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>> -#endif
>> -- 
>> 1.8.1.2
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
