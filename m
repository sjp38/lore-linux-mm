Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E87796B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 10:55:55 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so102874332pac.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 07:55:55 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ho5si2589025pad.175.2016.02.02.07.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 07:55:55 -0800 (PST)
Subject: Re: [PATCH] mm/slab: fix race with dereferencing NULL ptr in
 alloc_calls_show
References: <201602022324.wVKj7DGl%fengguang.wu@intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <56B0D17B.4050703@virtuozzo.com>
Date: Tue, 2 Feb 2016 18:55:39 +0300
MIME-Version: 1.0
In-Reply-To: <201602022324.wVKj7DGl%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>

On 02/02/2016 06:19 PM, kbuild test robot wrote:
> Hi Dmitry,
>
> [auto build test ERROR on v4.5-rc2]
> [also build test ERROR on next-20160201]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Dmitry-Safonov/mm-slab-fix-race-with-dereferencing-NULL-ptr-in-alloc_calls_show/20160202-230449
> config: i386-randconfig-x005-02010231 (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=i386
Thanks little robot, will resend fixed v2 right soon.
>
> All errors (new ones prefixed by >>):
>
>     mm/slab_common.c: In function 'memcg_destroy_kmem_caches':
>>> mm/slab_common.c:613:3: error: implicit declaration of function 'sysfs_slab_remove' [-Werror=implicit-function-declaration]
>        sysfs_slab_remove(s);
>        ^
>     cc1: some warnings being treated as errors
>
> vim +/sysfs_slab_remove +613 mm/slab_common.c
>
>     607	
>     608		mutex_lock(&slab_mutex);
>     609		list_for_each_entry_safe(s, s2, &slab_caches, list) {
>     610			if (is_root_cache(s) || s->memcg_params.memcg != memcg)
>     611				continue;
>     612	
>   > 613			sysfs_slab_remove(s);
>     614	
>     615			/*
>     616			 * The cgroup is about to be freed and therefore has no charges
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
