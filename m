Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 16E5A6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 19:53:39 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id dn14so7108456obc.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 16:53:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52057E8A.70601@zytor.com>
References: <1375954883-30225-1-git-send-email-tangchen@cn.fujitsu.com>
	<1375954883-30225-5-git-send-email-tangchen@cn.fujitsu.com>
	<CAE9FiQXwAkGU96Oe5YNErTXs-OHGHTAfVo4oyrF-WUZ97X7pQA@mail.gmail.com>
	<5204B74B.4050805@cn.fujitsu.com>
	<CAE9FiQXe2SXN6KxfNBFZhZqJANZoVUprY2g=BYDzeYBUPWp-4A@mail.gmail.com>
	<52057E8A.70601@zytor.com>
Date: Fri, 9 Aug 2013 16:53:38 -0700
Message-ID: <CAE9FiQWQ1mWdg=JPfuoxaGOGftt25xQL6Oo-40M8PZqB-Ee_Rg@mail.gmail.com>
Subject: Re: [PATCH part4 4/4] x86, acpi, numa, mem_hotplug: Find hotpluggable
 memory in SRAT memory affinities.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, yanghy@cn.fujitsu.com, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Fri, Aug 9, 2013 at 4:43 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 08/09/2013 04:39 PM, Yinghai Lu wrote:
>>>>
>>>> Also parse srat table two times looks silly.
>>>
>>> By parsing SRAT twice, I can avoid memory allocation for acpi_tables_addr
>>> in acpi_initrd_override_copy() procedure at such an early time. This memory
>>> could also be in hotpluggable area.
>>
>> You already mark kernel position to be not hot-plugged,  so near the
>> kernel range should be safe to be put override acpi tables.
>>
>> also what I mean parse srat two times:
>> parse to get hotplug range, and late parse other numa info again.
>>
>
> Doing two passes over a small data structure (SRAT) would seem more
> sensible than allocating memory just to avoid that...

for x86 there is some numa info discovery path, and there are chance
srat is wrong but still have hotplug range there, or numa finally is using other
way or not used. Inconsistency looks weird.

numa_meminfo is static struct, we have way to get final numa info early enough
before we need use memblock to alloc buffer with it.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
