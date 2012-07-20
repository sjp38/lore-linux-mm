Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D10866B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:31:46 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AD8023EE0B6
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:31:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96E8D45DE56
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:31:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 788A445DE54
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:31:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 688691DB8047
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:31:44 +0900 (JST)
Received: from g01jpexchyt03.g01.fujitsu.local (g01jpexchyt03.g01.fujitsu.local [10.128.194.42])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19CE31DB8043
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 16:31:44 +0900 (JST)
Message-ID: <5009094B.3090506@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 16:31:23 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8] memory-hotplug : hot-remove physical memory(clear
 page table)
References: <5009038A.4090001@cn.fujitsu.com>
In-Reply-To: <5009038A.4090001@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

[Hi Wen,

Good news!! I was waiting for this patch to come.
Applying the patches, can we hot-remove physical memory completely?

Thanks,
Yasuaki Ishimatsu

2012/07/20 16:06, Wen Congyang wrote:
> This patch series aims to support physical memory hot-remove(clear page table).
>
> This patch series base on ishimatsu's patch series. You can get it here:
> http://www.spinics.net/lists/linux-acpi/msg36804.html
>
> The patches can remove following things:
>    - page table of removed memory
>
> If you find lack of function for physical memory hot-remove, please let me
> know.
>
> Note:
> * The patch "remove memory info from list before freeing it" is being disccussed
>    in other thread. But for testing the patch series, the patch is needed.
>    So I added the patch as [PATCH 0/8].
> * You need to apply ishimatsu's patch series first before applying this patch
>    series.
>
> Wen Congyang (8):
>    memory-hotplug: store the node id in acpi_memory_device
>    memory-hotplug: offline memory only when it is onlined
>    memory-hotplug: call remove_memory() to cleanup when removing memory
>      device
>    memory-hotplug: export the function acpi_bus_remove()
>    memory-hotplug: call acpi_bus_remove() to remove memory device
>    memory-hotplug: introduce new function arch_remove_memory()
>    x86: make __split_large_page() generally avialable
>    memory-hotplug: implement arch_remove_memory()
>
>   arch/ia64/mm/init.c                  |   16 ++++
>   arch/powerpc/mm/mem.c                |   14 +++
>   arch/s390/mm/init.c                  |    8 ++
>   arch/sh/mm/init.c                    |   15 +++
>   arch/tile/mm/init.c                  |    8 ++
>   arch/x86/include/asm/pgtable_types.h |    1 +
>   arch/x86/mm/init_32.c                |   10 ++
>   arch/x86/mm/init_64.c                |  160 ++++++++++++++++++++++++++++++++++
>   arch/x86/mm/pageattr.c               |   47 +++++-----
>   drivers/acpi/acpi_memhotplug.c       |   24 ++++--
>   drivers/acpi/scan.c                  |    3 +-
>   include/acpi/acpi_bus.h              |    1 +
>   include/linux/memory_hotplug.h       |    1 +
>   mm/memory_hotplug.c                  |    2 +-
>   14 files changed, 280 insertions(+), 30 deletions(-)
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
