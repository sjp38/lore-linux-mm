Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2F80E6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:39:58 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so1314135pdj.6
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:39:57 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1307510pdj.8
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:39:55 -0700 (PDT)
Message-ID: <5244553A.2050700@gmail.com>
Date: Thu, 26 Sep 2013 23:39:38 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3/6] x86/mm: Factor out of top-down direct mapping
 setup
References: <5241D897.1090905@gmail.com> <5241D9F2.80908@gmail.com> <20130926144642.GE3482@htj.dyndns.org>
In-Reply-To: <20130926144642.GE3482@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 09/26/2013 10:46 PM, Tejun Heo wrote:
> On Wed, Sep 25, 2013 at 02:29:06AM +0800, Zhang Yanfei wrote:
>> +/**
>> + * memory_map_top_down - Map [map_start, map_end) top down
>> + * @map_start: start address of the target memory range
>> + * @map_end: end address of the target memory range
>> + *
>> + * This function will setup direct mapping for memory range
>> + * [map_start, map_end) in top-down.
> 
> Can you please put a bit more effort into the function description?

Sorry.... I will try to make a more detailed description.

> 
> Other than that,
> 
>  Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
