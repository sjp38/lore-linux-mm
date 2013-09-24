Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 89A4B6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:54:24 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so4581826pbc.21
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:54:24 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so4565710pbb.20
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:54:21 -0700 (PDT)
Message-ID: <5241996B.5080701@gmail.com>
Date: Tue, 24 Sep 2013 21:53:47 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] x86/mem-hotplug: Support initialize page tables bottom
 up
References: <524162DA.30004@cn.fujitsu.com> <5241649B.3090302@cn.fujitsu.com> <20130924123340.GE2366@htj.dyndns.org> <52419264.3020409@gmail.com> <20130924132727.GI2366@htj.dyndns.org> <524194F6.4000101@gmail.com> <20130924133908.GJ2366@htj.dyndns.org>
In-Reply-To: <20130924133908.GJ2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hi tejun,

On 09/24/2013 09:39 PM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 24, 2013 at 09:34:46PM +0800, Zhang Yanfei wrote:
>>> But that wouldn't be ideal as we want the page tables above kernel
>>> image and the above would allocate it above ISA_END_ADDRESS, right?
>>
>> The original idea is we will allocate everything above the kernel. So
>> the pagetables for [ISA_END_ADDRESS, kernel_end) will be also located
>> above the kernel.
> 
> I'm a bit confused why we need two separate calls then.  What's the
> difference from calling with the whole range?

OK, this is just because we allocate pagtables just above the kernel.
And if we use up the BRK space that is reserved for inital pagetables,
we will use memblock to allocate memory for pagetables, and the memory
allocated here should be mapped already. So we first map [kernel_end, end)
to make memory above the kernel be mapped as soon as possible. And then
use pagetables allocated above the kernel to map [ISA_END_ADDRESS, kernel_end).

Thanks.

> 
> Thanks.
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
