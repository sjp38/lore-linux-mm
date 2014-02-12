Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C179C6B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 02:08:49 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so8667580pde.28
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 23:08:49 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id gj4si21648756pac.147.2014.02.11.23.08.46
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 23:08:48 -0800 (PST)
Message-ID: <52FB1E96.5010509@cn.fujitsu.com>
Date: Wed, 12 Feb 2014 15:11:18 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
References: <529D3FC0.6000403@cn.fujitsu.com> <529D4048.9070000@cn.fujitsu.com> <20140116171112.GB24740@suse.de> <52DCD065.7040408@cn.fujitsu.com> <20140120151409.GU4963@suse.de> <20140206101230.GA21345@suse.de> <52F86745.2060204@cn.fujitsu.com> <20140211110842.GI6732@suse.de>
In-Reply-To: <20140211110842.GI6732@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

Hi Mel,

On 02/11/2014 07:08 PM, Mel Gorman wrote:
......
>>>> I think they should be warned if the ratio is high and have an option of
>>>> specifying a ratio manually even if that means that additional nodes
>>>> will not be hot-removable.
>>
>> I think this is easy to do, provide an option for users to specify a
>> Normal:Movable ratio. This is not phys addr, and it is easy to use.
>>
>
> Yes. It would even be some help if the parameter forced some NUMA nodes
> to be Normal instead of Movable regardless of what SRAT says. There
> still would be an administrative burden in discovering what nodes are
> now pluggable but they must have been dealing with this already.
>

OK, I will start this work, and send patches soon.

>>>>
>>>> This is all still a kludge around the fact that node memory hot-remove
>>>> did not try and cope with full migration by breaking some of the 1:1
>>>> virt:phys mapping assumptions when hot-remove was enabled.
>>
>> I also said before, the implementation now can only be a temporary
>> solution for memory hotplug since it would take us a lot of time to
>> deal with 1:1 mapping thing.
>>
>> But about "breaking some of the 1:1 mapping", would you please give me
>> any hint of it ?  I want to do it too, but I cannot see where to start.
>>
>
> Some hints on how it might be tackled were given back in November 2012
> https://lkml.org/lkml/2012/11/29/190 but I never researched it in
> detail.
>

Thank you very much. I will read it one more time, and start trying to
migrate some of the kernel pages first.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
