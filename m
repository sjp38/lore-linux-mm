Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 57A036B0032
	for <linux-mm@kvack.org>; Sun,  6 Oct 2013 19:06:47 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so6292477pdj.26
        for <linux-mm@kvack.org>; Sun, 06 Oct 2013 16:06:47 -0700 (PDT)
Message-ID: <1381100583.5429.96.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 update 6/6] mem-hotplug: Introduce movable_node
 boot option
From: Toshi Kani <toshi.kani@hp.com>
Date: Sun, 06 Oct 2013 17:03:03 -0600
In-Reply-To: <5251772A.2050509@gmail.com>
References: <524E2032.4020106@gmail.com> <524E21BC.7090104@gmail.com>
	 <1381012134.5429.86.camel@misato.fc.hp.com> <5251772A.2050509@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Sun, 2013-10-06 at 14:43 +0000, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> The hot-Pluggable field in SRAT specifies which memory is hotpluggable.
> As we mentioned before, if hotpluggable memory is used by the kernel,
> it cannot be hot-removed. So memory hotplug users may want to set all
> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use it.
> 
> Memory hotplug users may also set a node as movable node, which has
> ZONE_MOVABLE only, so that the whole node can be hot-removed.
> 
> But the kernel cannot use memory in ZONE_MOVABLE. By doing this, the
> kernel cannot use memory in movable nodes. This will cause NUMA
> performance down. And other users may be unhappy.
> 
> So we need a way to allow users to enable and disable this functionality.
> In this patch, we introduce movable_node boot option to allow users to
> choose to not to consume hotpluggable memory at early boot time and
> later we can set it as ZONE_MOVABLE.
> 
> To achieve this, the movable_node boot option will control the memblock
> allocation direction. That said, after memblock is ready, before SRAT is
> parsed, we should allocate memory near the kernel image as we explained
> in the previous patches. So if movable_node boot option is set, the kernel
> does the following:
> 
> 1. After memblock is ready, make memblock allocate memory bottom up.
> 2. After SRAT is parsed, make memblock behave as default, allocate memory
>    top down.
> 
> Users can specify "movable_node" in kernel commandline to enable this
> functionality. For those who don't use memory hotplug or who don't want
> to lose their NUMA performance, just don't specify anything. The kernel
> will work as before.
> 
> Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Thanks for the quick update.

Acked-by: Toshi Kani <toshi.kani@hp.com>

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
