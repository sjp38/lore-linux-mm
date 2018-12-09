Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4178E0004
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 07:03:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so4045872edr.7
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 04:03:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m37sor4780927edd.6.2018.12.09.04.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 04:03:25 -0800 (PST)
Date: Sun, 9 Dec 2018 12:03:23 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
Message-ID: <20181209120323.lotz4v2ahywtk3hk@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <201812080950.q5whdIbk%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201812080950.q5whdIbk%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, kbuild-all@01.org, linux-mm@kvack.org, mgorman@techsingularity.net, akpm@linux-foundation.org

On Sat, Dec 08, 2018 at 09:42:29AM +0800, kbuild test robot wrote:
>Hi Wei,
>
>Thank you for the patch! Perhaps something to improve:
>
>[auto build test WARNING on linus/master]
>[also build test WARNING on v4.20-rc5 next-20181207]
>[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
>url:    https://github.com/0day-ci/linux/commits/Wei-Yang/mm-pageblock-make-sure-pageblock-won-t-exceed-mem_sectioin/20181207-030601
>config: powerpc-allmodconfig (attached as .config)
>compiler: powerpc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>reproduce:
>        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>        chmod +x ~/bin/make.cross
>        # save the attached .config to linux build tree
>        GCC_VERSION=7.2.0 make.cross ARCH=powerpc 
>
>All warnings (new ones prefixed by >>):
>
>   In file included from include/linux/gfp.h:6:0,
>                    from include/linux/xarray.h:14,
>                    from include/linux/radix-tree.h:31,
>                    from include/linux/fs.h:15,
>                    from include/linux/compat.h:17,
>                    from arch/powerpc/kernel/asm-offsets.c:16:
>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>    #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>         ^~~~~~~~~~~~~~~
>--
>   In file included from include/linux/gfp.h:6:0,
>                    from include/linux/mm.h:10,
>                    from mm//swap.c:16:
>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>    #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>         ^~~~~~~~~~~~~~~
>   In file included from include/linux/gfp.h:6:0,
>                    from include/linux/mm.h:10,
>                    from mm//swap.c:16:
>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>    #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>         ^~~~~~~~~~~~~~~
>
>vim +/pageblock_order +1088 include/linux/mmzone.h
>
>  1087	
>> 1088	#if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>  1089	#error Allocator pageblock_order exceeds SECTION_SIZE
>  1090	#endif
>  1091	
>

I took a look at the latest code, at line 1082 of the same file uses
pageblock_order. And I apply this patch on top of v4.20-rc5, the build
looks good to me.

Confused why this introduce an compile error.

>---
>0-DAY kernel test infrastructure                Open Source Technology Center
>https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



-- 
Wei Yang
Help you, Help me
