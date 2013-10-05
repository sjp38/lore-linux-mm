Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A3C1C6B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 18:12:44 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so5456813pdj.25
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 15:12:44 -0700 (PDT)
Message-ID: <1381010945.5429.78.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Toshi Kani <toshi.kani@hp.com>
Date: Sat, 05 Oct 2013 16:09:05 -0600
In-Reply-To: <524E2127.4090904@gmail.com>
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri, 2013-10-04 at 10:00 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> The Linux kernel cannot migrate pages used by the kernel. As a
> result, kernel pages cannot be hot-removed. So we cannot allocate
> hotpluggable memory for the kernel.
> 
> In a memory hotplug system, any numa node the kernel resides in
> should be unhotpluggable. And for a modern server, each node could
> have at least 16GB memory. So memory around the kernel image is
> highly likely unhotpluggable.
> 
> ACPI SRAT (System Resource Affinity Table) contains the memory
> hotplug info. But before SRAT is parsed, memblock has already
> started to allocate memory for the kernel. So we need to prevent
> memblock from doing this.
> 
> So direct memory mapping page tables setup is the case. init_mem_mapping()
> is called before SRAT is parsed. To prevent page tables being allocated
> within hotpluggable memory, we will use bottom-up direction to allocate
> page tables from the end of kernel image to the higher memory.
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
