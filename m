Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9D04A6B0038
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:46:50 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so1262109pdi.28
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:46:50 -0700 (PDT)
Received: by mail-ye0-f177.google.com with SMTP id q9so403967yen.8
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:46:47 -0700 (PDT)
Date: Thu, 26 Sep 2013 10:46:42 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 3/6] x86/mm: Factor out of top-down direct mapping
 setup
Message-ID: <20130926144642.GE3482@htj.dyndns.org>
References: <5241D897.1090905@gmail.com>
 <5241D9F2.80908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5241D9F2.80908@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Sep 25, 2013 at 02:29:06AM +0800, Zhang Yanfei wrote:
> +/**
> + * memory_map_top_down - Map [map_start, map_end) top down
> + * @map_start: start address of the target memory range
> + * @map_end: end address of the target memory range
> + *
> + * This function will setup direct mapping for memory range
> + * [map_start, map_end) in top-down.

Can you please put a bit more effort into the function description?

Other than that,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
