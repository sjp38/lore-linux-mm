Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E95836B740A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:20:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so9705877edz.15
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:20:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a101si5073073edf.386.2018.12.05.03.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:20:04 -0800 (PST)
Date: Wed, 5 Dec 2018 11:20:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [mmotm:master 128/293] kernel/sysctl.o:undefined reference to
 `fragment_stall_order_sysctl_handler'
Message-ID: <20181205112001.GD31508@suse.de>
References: <201812051704.QejGRMmV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201812051704.QejGRMmV%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Dec 05, 2018 at 05:12:06PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7072a0ce81c613d27563eed5425727d1d8791f58
> commit: e3e68607541c60671eb3499a2c064d2f71626da4 [128/293] mm: stall movable allocations until kswapd progresses during serious external fragmentation event
> config: c6x-evmc6678_defconfig (attached as .config)
> compiler: c6x-elf-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout e3e68607541c60671eb3499a2c064d2f71626da4
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.1.0 make.cross ARCH=c6x 
> 
> All errors (new ones prefixed by >>):
> 

This appears to be some sort of glitch in Andrew's tree. It works in
mmots and is broken in mmotm. The problem is that with mmotm, the
fragment_stall_order_sysctl_handler handler has moved below
sysctl_min_slab_ratio_sysctl_handler instead of below
watermark_boost_factor_sysctl_handler where it belongs.

Now, while this could be fixed, in this specific instance I would prefer
the patch be dropped entirely because there are some potential downsides
that are potentially distracting and the supporting data is not strong
enough too justify the potential downsides.

Andrew?

-- 
Mel Gorman
SUSE Labs
