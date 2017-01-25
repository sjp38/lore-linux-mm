Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 872BC6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:53:23 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id o12so82416617lfg.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:53:23 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id e78si14234561lfi.269.2017.01.25.00.53.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 00:53:22 -0800 (PST)
Subject: Re: [mmotm:master 214/330] mm/memory-failure.c:1656: error: implicit
 declaration of function 'isolate_movable_page'
References: <201701251628.dBqAa7Kt%fengguang.wu@intel.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <ddfb4d5e-231d-68ab-6544-18b7ae2b95f4@huawei.com>
Date: Wed, 25 Jan 2017 16:46:55 +0800
MIME-Version: 1.0
In-Reply-To: <201701251628.dBqAa7Kt%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux
 Memory Management List <linux-mm@kvack.org>, Hanjun Guo <guohanjun@huawei.com>

hi,fengguang,
This is because function isolate_movable_page depend on CONFIG_MIGRATION which
is not enable.

I will submit a patchset to resolve it soon.
Sorry about that.

Thanks
Yisheng Xie.


On 2017/1/25 16:05, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f7bc4a69dcfb1f03014b95e88b6a468f8cbf2d43
> commit: 2cef0f79dcb7450917e324c8d26cdbe58097da31 [214/330] HWPOISON: soft offlining for non-lru movable pages
> config: x86_64-randconfig-b0-01251455 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         git checkout 2cef0f79dcb7450917e324c8d26cdbe58097da31
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/memory-failure.c: In function '__soft_offline_page':
>>> mm/memory-failure.c:1656: error: implicit declaration of function 'isolate_movable_page'
> 
> vim +/isolate_movable_page +1656 mm/memory-failure.c
> 
>   1650		 * Try to migrate to a new page instead. migrate.c
>   1651		 * handles a large number of cases for us.
>   1652		 */
>   1653		if (PageLRU(page))
>   1654			ret = isolate_lru_page(page);
>   1655		else
>> 1656			ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>   1657		/*
>   1658		 * Drop page reference which is came from get_any_page()
>   1659		 * successful isolate_lru_page() already took another one.
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
