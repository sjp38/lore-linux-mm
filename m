Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CA4A96B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 15:10:36 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1391776pdj.8
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:10:36 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id to1so2994155ieb.9
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:10:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131009164449.GG22495@htj.dyndns.org>
References: <524E2032.4020106@gmail.com>
	<524E2127.4090904@gmail.com>
	<5251F9AB.6000203@zytor.com>
	<525442A4.9060709@gmail.com>
	<20131009164449.GG22495@htj.dyndns.org>
Date: Wed, 9 Oct 2013 12:10:34 -0700
Message-ID: <CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Wed, Oct 9, 2013 at 9:44 AM, Tejun Heo <tj@kernel.org> wrote:
>> consume the precious lower memory. So I think we may really reorder
>> the page table setup after we get the hotplug info in some way. Just like
>> we have done in patch 5, we reorder reserve_crashkernel() to be called
>> after initmem_init().
>>
>> So do you still have any objection to the pagetable setup reorder?
>
> I still feel quite uneasy about pulling SRAT parsing and ACPI initrd
> overriding into early boot.

for your reconsidering to parse srat early, I refresh that old patchset
at

https://git.kernel.org/cgit/linux/kernel/git/yinghai/linux-yinghai.git/log/?h=for-x86-mm-3.13

actually looks one-third or haf patches already have your ack.


Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
