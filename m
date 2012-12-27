Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 89F1D6B005A
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 22:10:32 -0500 (EST)
Message-ID: <50DBBBEF.70701@cn.fujitsu.com>
Date: Thu, 27 Dec 2012 11:09:35 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 04/14] memory-hotplug: remove /sys/firmware/memmap/X
 sysfs
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-5-git-send-email-tangchen@cn.fujitsu.com> <50DA6F5A.2070601@jp.fujitsu.com>
In-Reply-To: <50DA6F5A.2070601@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 12/26/2012 11:30 AM, Kamezawa Hiroyuki wrote:
>> @@ -41,6 +42,7 @@ struct firmware_map_entry {
>>    	const char		*type;	/* type of the memory range */
>>    	struct list_head	list;	/* entry for the linked list */
>>    	struct kobject		kobj;   /* kobject for each entry */
>> +	unsigned int		bootmem:1; /* allocated from bootmem */
>>    };
> 
> Can't we detect from which the object is allocated from, slab or bootmem ?
> 
> Hm, for example,
> 
>      PageReserved(virt_to_page(address_of_obj)) ?
>      PageSlab(virt_to_page(address_of_obj)) ?
> 

Hi Kamezawa-san,

I think we can detect it without a new member. I think bootmem:1 member
is just for convenience. I think I can remove it. :)

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
