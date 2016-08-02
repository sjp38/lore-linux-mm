Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 884496B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 01:35:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so311532898pfd.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 22:35:20 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id f66si1195702pfc.168.2016.08.01.22.35.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 22:35:19 -0700 (PDT)
Subject: Re: [PATCH] mm/memblock.c: fix NULL dereference error
References: <201608021315.YmAh1zzr%fengguang.wu@intel.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57A03083.7010003@zoho.com>
Date: Tue, 2 Aug 2016 13:32:51 +0800
MIME-Version: 1.0
In-Reply-To: <201608021315.YmAh1zzr%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, ard.biesheuvel@linaro.org, david@gibson.dropbear.id.au, dev@g0hl1n.net, kuleshovmail@gmail.com, tangchen@cn.fujitsu.com, tj@kernel.org, weiyang@linux.vnet.ibm.com, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

i am sorry, the second patch is only a test patch, please don't apply it
i will send another mail for correct this

On 08/02/2016 01:23 PM, kbuild test robot wrote:
> Hi zijun_hu,
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.7 next-20160801]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/zijun_hu/mm-memblock-c-fix-NULL-dereference-error/20160802-130708
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: i386-randconfig-x009-201631 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/kernel.h:13:0,
>                     from mm/memblock.c:13:
>    mm/memblock.c: In function 'memblock_patch_verify':
>>> mm/memblock.c:1713:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 3 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>>> mm/memblock.c:1713:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
>    mm/memblock.c:1713:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 4 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>>> mm/memblock.c:1713:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
>    mm/memblock.c:1719:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 3 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>    mm/memblock.c:1719:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
>    mm/memblock.c:1719:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 4 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>    mm/memblock.c:1719:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
>    mm/memblock.c:1726:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 3 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>    mm/memblock.c:1726:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
>    mm/memblock.c:1726:11: warning: format '%llx' expects argument of type 'long long unsigned int', but argument 4 has type 'phys_addr_t {aka unsigned int}' [-Wformat=]
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>               ^
>    include/linux/printk.h:260:21: note: in definition of macro 'pr_fmt'
>     #define pr_fmt(fmt) fmt
>                         ^~~
>    mm/memblock.c:1726:3: note: in expansion of macro 'pr_info'
>       pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>       ^~~~~~~
> 
> vim +1713 mm/memblock.c
> 
>   1697		pr_info(" memory size = %#llx reserved size = %#llx\n",
>   1698			(unsigned long long)memblock.memory.total_size,
>   1699			(unsigned long long)memblock.reserved.total_size);
>   1700	
>   1701		memblock_dump(&memblock.memory, "memory");
>   1702		memblock_dump(&memblock.reserved, "reserved");
>   1703	}
>   1704	
>   1705	void __init_memblock memblock_patch_verify(void)
>   1706	{
>   1707		u64 i;
>   1708		phys_addr_t this_start, this_end;
>   1709	
>   1710		pr_info("in %s: memory\n", __func__);
>   1711		for_each_mem_range_rev(i, &memblock.memory, NULL, NUMA_NO_NODE,
>   1712				MEMBLOCK_NONE, &this_start, &this_end, NULL)
>> 1713			pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>   1714					i, this_start, this_end);
>   1715	
>   1716		pr_info("in %s: reserved\n", __func__);
>   1717		for_each_mem_range_rev(i, &memblock.reserved, NULL, NUMA_NO_NODE,
>   1718				MEMBLOCK_NONE, &this_start, &this_end, NULL)
>   1719			pr_info("[%#016llx]\t[%#016llx-%#016llx]\n",
>   1720					i, this_start, this_end);
>   1721	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
