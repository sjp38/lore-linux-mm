Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5EA6B796D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:18:14 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id v8so11071740ioq.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:18:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor21709431jaa.13.2018.12.06.02.18.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 02:18:12 -0800 (PST)
MIME-Version: 1.0
References: <201812051539.wULaKy8B%fengguang.wu@intel.com>
In-Reply-To: <201812051539.wULaKy8B%fengguang.wu@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 11:18:01 +0100
Message-ID: <CAAeHK+x_Wz=SAX+Yekdiai-TPCxFTh1gFovHRHeG1TjszH=PFA@mail.gmail.com>
Subject: Re: [mmotm:master 45/283] mm/kasan/common.c:238:7: error: 'struct
 kmem_cache' has no member named 'kasan_info'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Dec 5, 2018 at 8:09 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Andrey,
>
> First bad commit (maybe != root cause):
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   1b1ce5151f3dd9a5bc989207ac56e96dcb84bef4
> commit: 60e8d1374609a0f5846f0c8ac1c7907501b58c7e [45/283] kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
> config: x86_64-randconfig-x007-12051024 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 60e8d1374609a0f5846f0c8ac1c7907501b58c7e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All error/warnings (new ones prefixed by >>):

Looks like the same issues with configs, will fix in v13.

>
>    mm/kasan/common.c: In function 'kasan_cache_create':
> >> mm/kasan/common.c:238:7: error: 'struct kmem_cache' has no member named 'kasan_info'
>      cache->kasan_info.alloc_meta_offset = *size;
>           ^~
>    mm/kasan/common.c:244:8: error: 'struct kmem_cache' has no member named 'kasan_info'
>       cache->kasan_info.free_meta_offset = *size;
>            ^~
>    mm/kasan/common.c:260:20: error: 'struct kmem_cache' has no member named 'kasan_info'
>      if (*size <= cache->kasan_info.alloc_meta_offset ||
>                        ^~
>    mm/kasan/common.c:261:18: error: 'struct kmem_cache' has no member named 'kasan_info'
>        *size <= cache->kasan_info.free_meta_offset) {
>                      ^~
>    mm/kasan/common.c:262:8: error: 'struct kmem_cache' has no member named 'kasan_info'
>       cache->kasan_info.alloc_meta_offset = 0;
>            ^~
>    mm/kasan/common.c:263:8: error: 'struct kmem_cache' has no member named 'kasan_info'
>       cache->kasan_info.free_meta_offset = 0;
>            ^~
>    mm/kasan/common.c: In function 'kasan_metadata_size':
>    mm/kasan/common.c:273:15: error: 'struct kmem_cache' has no member named 'kasan_info'
>      return (cache->kasan_info.alloc_meta_offset ?
>                   ^~
>    mm/kasan/common.c:275:9: error: 'struct kmem_cache' has no member named 'kasan_info'
>       (cache->kasan_info.free_meta_offset ?
>             ^~
>    mm/kasan/common.c: In function 'get_alloc_info':
>    mm/kasan/common.c:283:31: error: 'struct kmem_cache' has no member named 'kasan_info'
>      return (void *)object + cache->kasan_info.alloc_meta_offset;
>                                   ^~
>    mm/kasan/common.c: In function 'get_free_info':
>    mm/kasan/common.c:290:31: error: 'struct kmem_cache' has no member named 'kasan_info'
>      return (void *)object + cache->kasan_info.free_meta_offset;
>                                   ^~
>    In file included from include/linux/export.h:45:0,
>                     from mm/kasan/common.c:16:
>    mm/kasan/common.c: In function '__kasan_slab_free':
> >> mm/kasan/common.c:336:15: error: implicit declaration of function 'nearest_obj' [-Werror=implicit-function-declaration]
>      if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
>                   ^
>    include/linux/compiler.h:77:42: note: in definition of macro 'unlikely'
>     # define unlikely(x) __builtin_expect(!!(x), 0)
>                                              ^
> >> mm/kasan/common.c:336:69: warning: comparison between pointer and integer
>      if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
>                                                                         ^
>    include/linux/compiler.h:77:42: note: in definition of macro 'unlikely'
>     # define unlikely(x) __builtin_expect(!!(x), 0)
>                                              ^
>    mm/kasan/common.c: In function 'kasan_metadata_size':
> >> mm/kasan/common.c:277:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
>    mm/kasan/common.c: In function 'get_alloc_info':
>    mm/kasan/common.c:284:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
>    mm/kasan/common.c: In function 'get_free_info':
>    mm/kasan/common.c:291:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
>    cc1: some warnings being treated as errors
> --
>    mm/kasan/report.c: In function 'print_address_description':
> >> mm/kasan/report.c:261:18: error: implicit declaration of function 'nearest_obj' [-Werror=implicit-function-declaration]
>       void *object = nearest_obj(cache, page, addr);
>                      ^~~~~~~~~~~
> >> mm/kasan/report.c:261:18: warning: initialization makes pointer from integer without a cast [-Wint-conversion]
>    cc1: some warnings being treated as errors
>
> vim +238 mm/kasan/common.c
>
> 6d7b7611 Andrey Konovalov 2018-11-29  230
> 6d7b7611 Andrey Konovalov 2018-11-29  231  void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
> 6d7b7611 Andrey Konovalov 2018-11-29  232                       slab_flags_t *flags)
> 6d7b7611 Andrey Konovalov 2018-11-29  233  {
> 6d7b7611 Andrey Konovalov 2018-11-29  234       unsigned int orig_size = *size;
> 6d7b7611 Andrey Konovalov 2018-11-29  235       int redzone_adjust;
> 6d7b7611 Andrey Konovalov 2018-11-29  236
> 6d7b7611 Andrey Konovalov 2018-11-29  237       /* Add alloc meta. */
> 6d7b7611 Andrey Konovalov 2018-11-29 @238       cache->kasan_info.alloc_meta_offset = *size;
> 6d7b7611 Andrey Konovalov 2018-11-29  239       *size += sizeof(struct kasan_alloc_meta);
> 6d7b7611 Andrey Konovalov 2018-11-29  240
> 6d7b7611 Andrey Konovalov 2018-11-29  241       /* Add free meta. */
> 6d7b7611 Andrey Konovalov 2018-11-29  242       if (cache->flags & SLAB_TYPESAFE_BY_RCU || cache->ctor ||
> 6d7b7611 Andrey Konovalov 2018-11-29  243           cache->object_size < sizeof(struct kasan_free_meta)) {
> 6d7b7611 Andrey Konovalov 2018-11-29  244               cache->kasan_info.free_meta_offset = *size;
> 6d7b7611 Andrey Konovalov 2018-11-29  245               *size += sizeof(struct kasan_free_meta);
> 6d7b7611 Andrey Konovalov 2018-11-29  246       }
> 6d7b7611 Andrey Konovalov 2018-11-29  247       redzone_adjust = optimal_redzone(cache->object_size) -
> 6d7b7611 Andrey Konovalov 2018-11-29  248               (*size - cache->object_size);
> 6d7b7611 Andrey Konovalov 2018-11-29  249
> 6d7b7611 Andrey Konovalov 2018-11-29  250       if (redzone_adjust > 0)
> 6d7b7611 Andrey Konovalov 2018-11-29  251               *size += redzone_adjust;
> 6d7b7611 Andrey Konovalov 2018-11-29  252
> 6d7b7611 Andrey Konovalov 2018-11-29  253       *size = min_t(unsigned int, KMALLOC_MAX_SIZE,
> 6d7b7611 Andrey Konovalov 2018-11-29  254                       max(*size, cache->object_size +
> 6d7b7611 Andrey Konovalov 2018-11-29  255                                       optimal_redzone(cache->object_size)));
> 6d7b7611 Andrey Konovalov 2018-11-29  256
> 6d7b7611 Andrey Konovalov 2018-11-29  257       /*
> 6d7b7611 Andrey Konovalov 2018-11-29  258        * If the metadata doesn't fit, don't enable KASAN at all.
> 6d7b7611 Andrey Konovalov 2018-11-29  259        */
> 6d7b7611 Andrey Konovalov 2018-11-29  260       if (*size <= cache->kasan_info.alloc_meta_offset ||
> 6d7b7611 Andrey Konovalov 2018-11-29  261                       *size <= cache->kasan_info.free_meta_offset) {
> 6d7b7611 Andrey Konovalov 2018-11-29  262               cache->kasan_info.alloc_meta_offset = 0;
> 6d7b7611 Andrey Konovalov 2018-11-29  263               cache->kasan_info.free_meta_offset = 0;
> 6d7b7611 Andrey Konovalov 2018-11-29  264               *size = orig_size;
> 6d7b7611 Andrey Konovalov 2018-11-29  265               return;
> 6d7b7611 Andrey Konovalov 2018-11-29  266       }
> 6d7b7611 Andrey Konovalov 2018-11-29  267
> 6d7b7611 Andrey Konovalov 2018-11-29  268       *flags |= SLAB_KASAN;
> 6d7b7611 Andrey Konovalov 2018-11-29  269  }
> 6d7b7611 Andrey Konovalov 2018-11-29  270
> 6d7b7611 Andrey Konovalov 2018-11-29  271  size_t kasan_metadata_size(struct kmem_cache *cache)
> 6d7b7611 Andrey Konovalov 2018-11-29  272  {
> 6d7b7611 Andrey Konovalov 2018-11-29  273       return (cache->kasan_info.alloc_meta_offset ?
> 6d7b7611 Andrey Konovalov 2018-11-29  274               sizeof(struct kasan_alloc_meta) : 0) +
> 6d7b7611 Andrey Konovalov 2018-11-29  275               (cache->kasan_info.free_meta_offset ?
> 6d7b7611 Andrey Konovalov 2018-11-29  276               sizeof(struct kasan_free_meta) : 0);
> 6d7b7611 Andrey Konovalov 2018-11-29 @277  }
> 6d7b7611 Andrey Konovalov 2018-11-29  278
> 6d7b7611 Andrey Konovalov 2018-11-29  279  struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> 6d7b7611 Andrey Konovalov 2018-11-29  280                                       const void *object)
> 6d7b7611 Andrey Konovalov 2018-11-29  281  {
> 6d7b7611 Andrey Konovalov 2018-11-29  282       BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
> 6d7b7611 Andrey Konovalov 2018-11-29  283       return (void *)object + cache->kasan_info.alloc_meta_offset;
> 6d7b7611 Andrey Konovalov 2018-11-29  284  }
> 6d7b7611 Andrey Konovalov 2018-11-29  285
> 6d7b7611 Andrey Konovalov 2018-11-29  286  struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> 6d7b7611 Andrey Konovalov 2018-11-29  287                                     const void *object)
> 6d7b7611 Andrey Konovalov 2018-11-29  288  {
> 6d7b7611 Andrey Konovalov 2018-11-29  289       BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
> 6d7b7611 Andrey Konovalov 2018-11-29 @290       return (void *)object + cache->kasan_info.free_meta_offset;
> 6d7b7611 Andrey Konovalov 2018-11-29  291  }
> 6d7b7611 Andrey Konovalov 2018-11-29  292
> 6d7b7611 Andrey Konovalov 2018-11-29  293  void kasan_poison_slab(struct page *page)
> 6d7b7611 Andrey Konovalov 2018-11-29  294  {
> 6d7b7611 Andrey Konovalov 2018-11-29  295       kasan_poison_shadow(page_address(page),
> 6d7b7611 Andrey Konovalov 2018-11-29  296                       PAGE_SIZE << compound_order(page),
> 6d7b7611 Andrey Konovalov 2018-11-29  297                       KASAN_KMALLOC_REDZONE);
> 6d7b7611 Andrey Konovalov 2018-11-29  298  }
> 6d7b7611 Andrey Konovalov 2018-11-29  299
> 6d7b7611 Andrey Konovalov 2018-11-29  300  void kasan_unpoison_object_data(struct kmem_cache *cache, void *object)
> 6d7b7611 Andrey Konovalov 2018-11-29  301  {
> 6d7b7611 Andrey Konovalov 2018-11-29  302       kasan_unpoison_shadow(object, cache->object_size);
> 6d7b7611 Andrey Konovalov 2018-11-29  303  }
> 6d7b7611 Andrey Konovalov 2018-11-29  304
> 6d7b7611 Andrey Konovalov 2018-11-29  305  void kasan_poison_object_data(struct kmem_cache *cache, void *object)
> 6d7b7611 Andrey Konovalov 2018-11-29  306  {
> 6d7b7611 Andrey Konovalov 2018-11-29  307       kasan_poison_shadow(object,
> 6d7b7611 Andrey Konovalov 2018-11-29  308                       round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
> 6d7b7611 Andrey Konovalov 2018-11-29  309                       KASAN_KMALLOC_REDZONE);
> 6d7b7611 Andrey Konovalov 2018-11-29  310  }
> 6d7b7611 Andrey Konovalov 2018-11-29  311
> 6d7b7611 Andrey Konovalov 2018-11-29  312  void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
> 6d7b7611 Andrey Konovalov 2018-11-29  313  {
> 6d7b7611 Andrey Konovalov 2018-11-29  314       struct kasan_alloc_meta *alloc_info;
> 6d7b7611 Andrey Konovalov 2018-11-29  315
> 6d7b7611 Andrey Konovalov 2018-11-29  316       if (!(cache->flags & SLAB_KASAN))
> 6d7b7611 Andrey Konovalov 2018-11-29  317               return (void *)object;
> 6d7b7611 Andrey Konovalov 2018-11-29  318
> 6d7b7611 Andrey Konovalov 2018-11-29  319       alloc_info = get_alloc_info(cache, object);
> 6d7b7611 Andrey Konovalov 2018-11-29  320       __memset(alloc_info, 0, sizeof(*alloc_info));
> 6d7b7611 Andrey Konovalov 2018-11-29  321
> 6d7b7611 Andrey Konovalov 2018-11-29  322       return (void *)object;
> 6d7b7611 Andrey Konovalov 2018-11-29  323  }
> 6d7b7611 Andrey Konovalov 2018-11-29  324
> 6d7b7611 Andrey Konovalov 2018-11-29  325  void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
> 6d7b7611 Andrey Konovalov 2018-11-29  326  {
> 6d7b7611 Andrey Konovalov 2018-11-29  327       return kasan_kmalloc(cache, object, cache->object_size, flags);
> 6d7b7611 Andrey Konovalov 2018-11-29  328  }
> 6d7b7611 Andrey Konovalov 2018-11-29  329
> 6d7b7611 Andrey Konovalov 2018-11-29  330  static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
> 6d7b7611 Andrey Konovalov 2018-11-29  331                             unsigned long ip, bool quarantine)
> 6d7b7611 Andrey Konovalov 2018-11-29  332  {
> 6d7b7611 Andrey Konovalov 2018-11-29  333       s8 shadow_byte;
> 6d7b7611 Andrey Konovalov 2018-11-29  334       unsigned long rounded_up_size;
> 6d7b7611 Andrey Konovalov 2018-11-29  335
> 6d7b7611 Andrey Konovalov 2018-11-29 @336       if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
> 6d7b7611 Andrey Konovalov 2018-11-29  337           object)) {
> 6d7b7611 Andrey Konovalov 2018-11-29  338               kasan_report_invalid_free(object, ip);
> 6d7b7611 Andrey Konovalov 2018-11-29  339               return true;
> 6d7b7611 Andrey Konovalov 2018-11-29  340       }
> 6d7b7611 Andrey Konovalov 2018-11-29  341
> 6d7b7611 Andrey Konovalov 2018-11-29  342       /* RCU slabs could be legally used after free within the RCU period */
> 6d7b7611 Andrey Konovalov 2018-11-29  343       if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
> 6d7b7611 Andrey Konovalov 2018-11-29  344               return false;
> 6d7b7611 Andrey Konovalov 2018-11-29  345
> 6d7b7611 Andrey Konovalov 2018-11-29  346       shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
> 6d7b7611 Andrey Konovalov 2018-11-29  347       if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
> 6d7b7611 Andrey Konovalov 2018-11-29  348               kasan_report_invalid_free(object, ip);
> 6d7b7611 Andrey Konovalov 2018-11-29  349               return true;
> 6d7b7611 Andrey Konovalov 2018-11-29  350       }
> 6d7b7611 Andrey Konovalov 2018-11-29  351
> 6d7b7611 Andrey Konovalov 2018-11-29  352       rounded_up_size = round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE);
> 6d7b7611 Andrey Konovalov 2018-11-29  353       kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
> 6d7b7611 Andrey Konovalov 2018-11-29  354
> 6d7b7611 Andrey Konovalov 2018-11-29  355       if (!quarantine || unlikely(!(cache->flags & SLAB_KASAN)))
> 6d7b7611 Andrey Konovalov 2018-11-29  356               return false;
> 6d7b7611 Andrey Konovalov 2018-11-29  357
> 6d7b7611 Andrey Konovalov 2018-11-29  358       set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
> 6d7b7611 Andrey Konovalov 2018-11-29  359       quarantine_put(get_free_info(cache, object), cache);
> 6d7b7611 Andrey Konovalov 2018-11-29  360       return true;
> 6d7b7611 Andrey Konovalov 2018-11-29  361  }
> 6d7b7611 Andrey Konovalov 2018-11-29  362
>
> :::::: The code at line 238 was first introduced by commit
> :::::: 6d7b7611ded2d230f527485d39a7e74958de415a kasan: move common generic and tag-based code to common.c
>
> :::::: TO: Andrey Konovalov <andreyknvl@google.com>
> :::::: CC: Johannes Weiner <hannes@cmpxchg.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
