Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 846966B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:38:29 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id nk17so122300919igb.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 02:38:29 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 6si9970711igy.14.2016.03.31.02.38.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 02:38:29 -0700 (PDT)
Message-ID: <56FCEFFE.6040604@huawei.com>
Date: Thu, 31 Mar 2016 17:38:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] oom, but there is enough memory
References: <56FCEAD0.9080806@huawei.com> <20160331093011.GC27831@dhcp22.suse.cz>
In-Reply-To: <20160331093011.GC27831@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/3/31 17:30, Michal Hocko wrote:

> On Thu 31-03-16 17:16:00, Xishi Qiu wrote:
>> It triggers a lot of ooms, but there is enough memory(many large blocks).
>> And at last "Kernel panic - not syncing: Out of memory and no killable processes..."
>>
>> I find almost the every call trace include "pagefault_out_of_memory" and "gfp_mask=0x0".
>> If it does oom, why not it triger in mm core path? 
> 
> It seems that somebody in the page fault path has returned with
> VM_FAULT_OOM without invoking the page allocator and kept returning the
> same error until there is nothing killable and so the oom killer panics.
> 
> [...]
>> <4>[63651.040374s][pid:2912,cpu3,sh]DMA free:550600kB min:5244kB low:27580kB high:28892kB active_anon:343060kB inactive_anon:1224kB active_file:107596kB inactive_file:465156kB unevictable:1040kB isolated(anon):0kB isolated(file):0kB present:2016252kB managed:1720040kB mlocked:1040kB dirty:40kB writeback:0kB mapped:200420kB shmem:1312kB slab_reclaimable:27048kB slab_unreclaimable:73300kB kernel_stack:15248kB pagetables:14484kB unstable:0kB bounce:0kB free_cma:30896kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> 
> This is rather weird. DMA zone with 2GB? What kind of architecture is
> this?

Hi Michal,

It's arm64, so DMA is [0-4G], and Normal is [4G-]
Is that something wrong with the RAM hardware, then trigger the problem?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
