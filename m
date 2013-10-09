Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id ACEE16B0036
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 19:10:46 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1672655pdi.19
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 16:10:46 -0700 (PDT)
Message-ID: <5255E253.3080905@zytor.com>
Date: Wed, 09 Oct 2013 16:10:11 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com> <20131009192040.GA5592@mtj.dyndns.org> <1381352311.5429.115.camel@misato.fc.hp.com> <20131009211136.GH5592@mtj.dyndns.org> <5255C730.90602@zytor.com> <5255CE7D.8030007@gmail.com>
In-Reply-To: <5255CE7D.8030007@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 10/09/2013 02:45 PM, Zhang Yanfei wrote:
>>
>> I would also argue that in the VM scenario -- and arguable even in the
>> hardware scenario -- the right thing is to not expose the flexible
>> memory in the e820/EFI tables, and instead have it hotadded (possibly
>> *immediately* so) on boot.  This avoids both the boot time funnies as
>> well as the scaling issues with metadata.
>>
> 
> So in this kind of scenario, hotpluggable memory will not be detected
> at boot time, and admin should not use this movable_node boot option
> and the kernel will act as before, using top-down allocation always.
> 

Yes.  The idea is that the kernel will boot up without the hotplug
memory, but if desired, will immediately see a hotplug-add event for the
movable memory.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
