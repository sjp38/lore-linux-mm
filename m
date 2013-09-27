Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCAC6B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 18:45:18 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so3174383pdj.16
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 15:45:18 -0700 (PDT)
Message-ID: <1380321790.14046.49.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 3/6] x86/mm: Factor out of top-down direct mapping
 setup
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 27 Sep 2013 16:43:10 -0600
In-Reply-To: <5241D9F2.80908@gmail.com>
References: <5241D897.1090905@gmail.com> <5241D9F2.80908@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 2013-09-25 at 02:29 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> This patch creates a new function memory_map_top_down to
> factor out of the top-down direct memory mapping pagetable
> setup. This is also a preparation for the following patch,
> which will introduce the bottom-up memory mapping. That said,
> we will put the two ways of pagetable setup into separate
> functions, and choose to use which way in init_mem_mapping,
> which makes the code more clear.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
