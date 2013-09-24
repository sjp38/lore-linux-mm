Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id E43D26B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:07:58 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so4612887pbc.16
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:07:58 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so5026840pad.33
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 07:07:55 -0700 (PDT)
Message-ID: <52419C8F.4020201@gmail.com>
Date: Tue, 24 Sep 2013 22:07:11 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] x86/mem-hotplug: Support initialize page tables bottom
 up
References: <524162DA.30004@cn.fujitsu.com> <5241649B.3090302@cn.fujitsu.com> <20130924123340.GE2366@htj.dyndns.org> <52419264.3020409@gmail.com> <20130924132727.GI2366@htj.dyndns.org> <524194F6.4000101@gmail.com> <20130924133908.GJ2366@htj.dyndns.org> <5241996B.5080701@gmail.com> <20130924140545.GA517@mtj.dyndns.org>
In-Reply-To: <20130924140545.GA517@mtj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 09/24/2013 10:05 PM, Tejun Heo wrote:
> On Tue, Sep 24, 2013 at 09:53:47PM +0800, Zhang Yanfei wrote:
>> OK, this is just because we allocate pagtables just above the kernel.
>> And if we use up the BRK space that is reserved for inital pagetables,
>> we will use memblock to allocate memory for pagetables, and the memory
>> allocated here should be mapped already. So we first map [kernel_end, end)
>> to make memory above the kernel be mapped as soon as possible. And then
>> use pagetables allocated above the kernel to map [ISA_END_ADDRESS, kernel_end).
> 
> I see.  The code seems fine to me then.  Can you please add comment
> explaining why the split calls are necessary?

Okay, will add the comment.

Thanks.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
