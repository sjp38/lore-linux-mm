Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E2D826B0036
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:24:27 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so4621036pdi.0
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:24:27 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so4951446pab.36
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:24:25 -0700 (PDT)
Message-ID: <52419271.1090809@gmail.com>
Date: Tue, 24 Sep 2013 21:24:01 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86, acpi, crash, kdump: Do reserve_crashkernel()
 after SRAT is parsed.
References: <524162DA.30004@cn.fujitsu.com> <524164ED.3060201@cn.fujitsu.com> <20130924123428.GF2366@htj.dyndns.org>
In-Reply-To: <20130924123428.GF2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 09/24/2013 08:34 PM, Tejun Heo wrote:
> On Tue, Sep 24, 2013 at 06:09:49PM +0800, Zhang Yanfei wrote:
>> From: Tang Chen <tangchen@cn.fujitsu.com>
>>
>> Memory reserved for crashkernel could be large. So we should not allocate
>> this memory bottom up from the end of kernel image.
>>
>> When SRAT is parsed, we will be able to know whihc memory is hotpluggable,
>> and we can avoid allocating this memory for the kernel. So reorder
>> reserve_crashkernel() after SRAT is parsed.
>>
>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> Assuming this was tested to work.
> 
>  Acked-by: Tejun Heo <tj@kernel.org>

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
