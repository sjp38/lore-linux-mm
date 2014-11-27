Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id E2E736B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:13:26 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id vb8so3753565obc.0
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 05:13:26 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id s5si1014471oev.44.2014.11.27.05.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 05:13:24 -0800 (PST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so3656303obc.35
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 05:13:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201411271133.qSXTvdQZ%fengguang.wu@intel.com>
References: <201411271133.qSXTvdQZ%fengguang.wu@intel.com>
Date: Thu, 27 Nov 2014 21:13:23 +0800
Message-ID: <CADAEsF8RyCBBoxYozCOPXLkeZ0ioM2jPsqn_K-=S35CfkaKohw@mail.gmail.com>
Subject: Re: [mmotm:master 210/397] mm/zsmalloc.c:1021:11: error:
 'ZS_SIZE_CLASSES' undeclared
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hello, Fengguang:

2014-11-27 11:49 GMT+08:00 kbuild test robot <fengguang.wu@intel.com>:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a2d887dee78e23dc092ff14ae2ad22592437a328
> commit: 304e521b912aa95514a5b66f7d6795d096f15535 [210/397] mm/zsmalloc: support allocating obj with size of ZS_MAX_ALLOC_SIZE
> config: x86_64-randconfig-c2-1109 (attached as .config)
> reproduce:
>   git checkout 304e521b912aa95514a5b66f7d6795d096f15535
>   # save the attached .config to linux build tree
>   make ARCH=x86_64

I build the code based on mmotm-2014-11-26-15-45. It is OK.

$ git log --oneline mm/zsmalloc.c
dd0c2fe mm/zsmalloc: avoid duplicate assignment of prev_class
570fa7e mm/zsmalloc: support allocating obj with size of ZS_MAX_ALLOC_SIZE
5971356 zsmalloc: correct fragile [kmap|kunmap]_atomic use
29d6ab4 zsmalloc-fix-zs_init-cpu-notifier-error-handling-fix
58038f5a zsmalloc-fix-zs_init-cpu-notifier-error-handling-fix-2
ebc3b45 zsmalloc: fix zs_init cpu notifier error handling
890754a2 zsmalloc: merge size_class to reduce fragmentation
202c8f0 zsmalloc: simplify init_zspage free obj linking
a32a745 mm/zsmalloc.c: correct comment for fullness group computation
1faf944 zsmalloc: change return value unit of zs_get_total_size_bytes
440b6d5 zsmalloc: move pages_allocated to zs_pool
137f8cf mm/zpool: use prefixed module loading
c795779 mm/zpool: zbud/zsmalloc implement zpool
af8d417 mm/zpool: implement common zpool api to zbud/zsmalloc
f6f8ed4 mm/vmalloc.c: clean up map_vm_area third argument
7eb5251 zsmalloc: fixup trivial zs size classes value in comments
7c8e018 mm: replace __get_cpu_var uses with this_cpu_ptr
f0e71fc zsmalloc: Fix CPU hotplug callback registration
31fc00b zsmalloc: add copyright
bcf1647 zsmalloc: move it under mm

I do not know why the building on
*git://git.cmpxchg.org/linux-mmotm.git master* failed.
I am now cloning  code from git://git.cmpxchg.org/linux-mmotm.git.  I
will try later.

Thanks.

> Note: the mmotm/master HEAD a2d887dee78e23dc092ff14ae2ad22592437a328 builds fine.
>       It only hurts bisectibility.
>
> All error/warnings:
>
>    mm/zsmalloc.c: In function 'zs_create_pool':
>>> mm/zsmalloc.c:1021:11: error: 'ZS_SIZE_CLASSES' undeclared (first use in this function)
>       if (i < ZS_SIZE_CLASSES - 1) {
>               ^
>    mm/zsmalloc.c:1021:11: note: each undeclared identifier is reported only once for each function it appears in
>
> vim +/ZS_SIZE_CLASSES +1021 mm/zsmalloc.c
>
> 62a4dc89 Joonsoo Kim 2014-11-27  1015            * have one size_class for each size, there is a chance that we
> 62a4dc89 Joonsoo Kim 2014-11-27  1016            * can get more memory utilization if we use one size_class for
> 62a4dc89 Joonsoo Kim 2014-11-27  1017            * many different sizes whose size_class have same
> 62a4dc89 Joonsoo Kim 2014-11-27  1018            * characteristics. So, we makes size_class point to
> 62a4dc89 Joonsoo Kim 2014-11-27  1019            * previous size_class if possible.
> 62a4dc89 Joonsoo Kim 2014-11-27  1020            */
> 62a4dc89 Joonsoo Kim 2014-11-27 @1021           if (i < ZS_SIZE_CLASSES - 1) {
> 62a4dc89 Joonsoo Kim 2014-11-27  1022                   prev_class = pool->size_class[i + 1];
> 62a4dc89 Joonsoo Kim 2014-11-27  1023                   if (can_merge(prev_class, size, pages_per_zspage)) {
> 62a4dc89 Joonsoo Kim 2014-11-27  1024                           pool->size_class[i] = prev_class;
>
> :::::: The code at line 1021 was first introduced by commit
> :::::: 62a4dc89f79363e2456ce2fc68e5719ef528893f zsmalloc: merge size_class to reduce fragmentation
>
> :::::: TO: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> :::::: CC: Johannes Weiner <hannes@cmpxchg.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
