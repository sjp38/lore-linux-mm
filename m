Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 790706B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:10:12 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so4494064pbb.33
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:10:12 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id k4so2384966qaq.13
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 05:10:09 -0700 (PDT)
Date: Tue, 24 Sep 2013 08:10:05 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/6] memblock: Factor out of top-down allocation
Message-ID: <20130924121005.GB2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <5241636B.2060206@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5241636B.2060206@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, Sep 24, 2013 at 06:03:23PM +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> This patch imports a new function __memblock_find_range_rev

"imports" sounds a bit weird.  I think "creates" or "this patch
factors out __memblock_find_range_rev() from
memblock_find_in_range_node()" would be better.

> to factor out of top-down allocation from memblock_find_in_range_node.
> This is a preparation because we will introduce a new bottom-up
> allocation mode in the following patch.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
