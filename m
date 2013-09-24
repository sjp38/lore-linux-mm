Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8D47D6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 22:42:50 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id to1so7910555ieb.37
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:42:50 -0700 (PDT)
Message-ID: <5240FBEF.10102@cn.fujitsu.com>
Date: Tue, 24 Sep 2013 10:41:51 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/5] memblock: Improve memblock to support allocation
 from lower address.
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com> <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com> <20130923155027.GD14547@htj.dyndns.org> <52408351.8080400@gmail.com> <20130923202147.GB28667@mtj.dyndns.org>
In-Reply-To: <20130923202147.GB28667@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello tejun,

On 09/24/2013 04:21 AM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 24, 2013 at 02:07:13AM +0800, Zhang Yanfei wrote:
>> Yes, I am following your advice in principle but kind of confused by
>> something you said above. Where should the set_memblock_alloc_above_kernel
>> be used? IMO, the function is like:
>>
>> find_in_range_node()
>> {
>>      if (ok) {
>>            /* bottom-up */
>>            ret = __memblock_find_in_range(max(start, _end_of_kernel), end...);
>>            if (!ret)
>>                  return ret;
>>      }
>>
>>      /* top-down retry */
>>      return __memblock_find_in_range_rev(start, end...)
>> }
>>
>> For bottom-up allocation, we always start from max(start, _end_of_kernel).
> 
> Oh, I was talking about naming of the memblock_set_bottom_up()
> function.  We aren't really doing pure bottom up allocations, so I
> think it probably would be clearer if the name clearly denotes that
> we're doing above-kernel allocation.

I see. But I think memblock_set_alloc_above_kernel may lose the info
that we are doing bottom-up allocation. So my idea is we introduce
pure bottom-up allocation mode in previous patches and we use the
bottom-up allocation here and limit the start address above the kernel
, with explicit comments to indicate this.

How do you think?

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
