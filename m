Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 427EE6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:22:32 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id x13so7458755ief.1
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:22:32 -0700 (PDT)
Received: by mail-yh0-f42.google.com with SMTP id z12so1604114yhz.15
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:22:28 -0700 (PDT)
Date: Mon, 23 Sep 2013 16:21:47 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/5] memblock: Improve memblock to support allocation
 from lower address.
Message-ID: <20130923202147.GB28667@mtj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com>
 <20130923155027.GD14547@htj.dyndns.org>
 <52408351.8080400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52408351.8080400@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Tue, Sep 24, 2013 at 02:07:13AM +0800, Zhang Yanfei wrote:
> Yes, I am following your advice in principle but kind of confused by
> something you said above. Where should the set_memblock_alloc_above_kernel
> be used? IMO, the function is like:
> 
> find_in_range_node()
> {
>      if (ok) {
>            /* bottom-up */
>            ret = __memblock_find_in_range(max(start, _end_of_kernel), end...);
>            if (!ret)
>                  return ret;
>      }
> 
>      /* top-down retry */
>      return __memblock_find_in_range_rev(start, end...)
> }
> 
> For bottom-up allocation, we always start from max(start, _end_of_kernel).

Oh, I was talking about naming of the memblock_set_bottom_up()
function.  We aren't really doing pure bottom up allocations, so I
think it probably would be clearer if the name clearly denotes that
we're doing above-kernel allocation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
