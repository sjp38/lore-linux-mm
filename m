Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2169F6B0005
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 15:21:26 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ug1so22450017pab.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 12:21:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yj10si2796344pac.31.2016.06.08.12.21.16
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 12:21:21 -0700 (PDT)
Date: Thu, 9 Jun 2016 03:23:38 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Message-ID: <201606090310.QZjXVJvE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <1465411243-102618-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kbuild-all@01.org, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on v4.7-rc2]
[cannot apply to next-20160608]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Potapenko/mm-kasan-switch-SLUB-to-stackdepot-enable-memory-quarantine-for-SLUB/20160609-024216
config: parisc-c3000_defconfig (attached as .config)
compiler: hppa-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=parisc 

All errors (new ones prefixed by >>):

   mm/slub.c: In function 'calculate_sizes':
>> mm/slub.c:3357:24: error: passing argument 2 of 'kasan_cache_create' from incompatible pointer type [-Werror=incompatible-pointer-types]
     kasan_cache_create(s, &size, &s->flags);
                           ^
   In file included from include/linux/slab.h:127:0,
                    from mm/slub.c:18:
   include/linux/kasan.h:91:20: note: expected 'size_t * {aka unsigned int *}' but argument is of type 'long unsigned int *'
    static inline void kasan_cache_create(struct kmem_cache *cache,
                       ^
   cc1: some warnings being treated as errors

vim +/kasan_cache_create +3357 mm/slub.c

  3351			s->red_left_pad = sizeof(void *);
  3352			s->red_left_pad = ALIGN(s->red_left_pad, s->align);
  3353			size += s->red_left_pad;
  3354		}
  3355	#endif
  3356	
> 3357		kasan_cache_create(s, &size, &s->flags);
  3358	
  3359		/*
  3360		 * SLUB stores one object immediately after another beginning from

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--HlL+5n6rz5pIUxbD
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
sVYAAA==

--HlL+5n6rz5pIUxbD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
