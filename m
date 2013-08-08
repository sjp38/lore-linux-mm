Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id CE7326B0033
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 12:41:26 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id i18so5739834oag.29
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 09:41:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375954883-30225-5-git-send-email-tangchen@cn.fujitsu.com>
References: <1375954883-30225-1-git-send-email-tangchen@cn.fujitsu.com>
	<1375954883-30225-5-git-send-email-tangchen@cn.fujitsu.com>
Date: Thu, 8 Aug 2013 09:41:25 -0700
Message-ID: <CAE9FiQXwAkGU96Oe5YNErTXs-OHGHTAfVo4oyrF-WUZ97X7pQA@mail.gmail.com>
Subject: Re: [PATCH part4 4/4] x86, acpi, numa, mem_hotplug: Find hotpluggable
 memory in SRAT memory affinities.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, yanghy@cn.fujitsu.com, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Thu, Aug 8, 2013 at 2:41 AM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> In ACPI SRAT(System Resource Affinity Table), there is a memory affinity for each
> memory range in the system. In each memory affinity, there is a field indicating
> that if the memory range is hotpluggable.
>
> This patch parses all the memory affinities in SRAT only, and find out all the
> hotpluggable memory ranges in the system.

oh, no.

How do you make sure the SRAT's entries are right ?
later numa_init could reject srat table if srat ranges does not cover
e820 memmap.

Also parse srat table two times looks silly.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
