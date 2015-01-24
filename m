Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D2CD76B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 10:23:21 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so3446347pdb.11
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 07:23:21 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ko10si5771336pbd.171.2015.01.24.07.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jan 2015 07:23:20 -0800 (PST)
Message-ID: <54C3B8E5.7010002@codeaurora.org>
Date: Sat, 24 Jan 2015 07:23:17 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [mmotm:master 10/417] mm/page_alloc.c:5033:38: error: 'ARCH_PFN_OFFSET'
 undeclared
References: <201501240940.uDGVjj95%fengguang.wu@intel.com>
In-Reply-To: <201501240940.uDGVjj95%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 1/23/2015 5:35 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   c64429bcc60a702f19f5cfdb5c39277863278a8c
> commit: c2ae2ed329b6b540ea2cbf75a7d14f7ff194b296 [10/417] mm/page_alloc.c: don't offset memmap for flatmem
> config: mn10300-asb2364_defconfig (attached as .config)
> reproduce:
>    wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>    chmod +x ~/bin/make.cross
>    git checkout c2ae2ed329b6b540ea2cbf75a7d14f7ff194b296
>    # save the attached .config to linux build tree
>    make.cross ARCH=mn10300
>
> All error/warnings:
>
>     mm/page_alloc.c: In function 'alloc_node_mem_map':
>>> mm/page_alloc.c:5033:38: error: 'ARCH_PFN_OFFSET' undeclared (first use in this function)
>          offset = pgdat->node_start_pfn - ARCH_PFN_OFFSET;
>                                           ^
>     mm/page_alloc.c:5033:38: note: each undeclared identifier is reported only once for each function it appears in
>
> vim +/ARCH_PFN_OFFSET +5033 mm/page_alloc.c
>
>    5027		 */
>    5028		if (pgdat == NODE_DATA(0)) {
>    5029			mem_map = NODE_DATA(0)->node_mem_map;
>    5030	#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>    5031			if (page_to_pfn(mem_map) != pgdat->node_start_pfn) {
>    5032				if (IS_ENABLED(CONFIG_HAVE_MEMBLOCK_NODE_MAP))
>> 5033					offset = pgdat->node_start_pfn - ARCH_PFN_OFFSET;
>    5034				mem_map -= offset;
>    5035			}
>    5036	#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP || CONFIG_FLATMEM */
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
>

Andrew, can you drop this patch from mmotm for now? Vlastimil still had
some questions and I'm going to be on vacation next week.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
