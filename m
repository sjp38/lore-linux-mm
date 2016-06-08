Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0D096B0005
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 15:17:47 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l5so26610519ioa.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 12:17:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id d1si2801260pfa.23.2016.06.08.12.17.46
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 12:17:47 -0700 (PDT)
Date: Thu, 9 Jun 2016 02:08:24 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Message-ID: <201606090232.2E8KIS3u%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline
In-Reply-To: <1465411243-102618-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kbuild-all@01.org, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test WARNING on v4.7-rc2]
[cannot apply to next-20160608]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Potapenko/mm-kasan-switch-SLUB-to-stackdepot-enable-memory-quarantine-for-SLUB/20160609-024216
config: m68k-m5475evb_defconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All warnings (new ones prefixed by >>):

   mm/slub.c: In function 'calculate_sizes':
>> mm/slub.c:3357:2: warning: passing argument 2 of 'kasan_cache_create' from incompatible pointer type
     kasan_cache_create(s, &size, &s->flags);
     ^
   In file included from include/linux/slab.h:127:0,
                    from mm/slub.c:18:
   include/linux/kasan.h:91:20: note: expected 'size_t *' but argument is of type 'long unsigned int *'
    static inline void kasan_cache_create(struct kmem_cache *cache,
                       ^

vim +/kasan_cache_create +3357 mm/slub.c

  3341		if (flags & SLAB_RED_ZONE) {
  3342			/*
  3343			 * Add some empty padding so that we can catch
  3344			 * overwrites from earlier objects rather than let
  3345			 * tracking information or the free pointer be
  3346			 * corrupted if a user writes before the start
  3347			 * of the object.
  3348			 */
  3349			size += sizeof(void *);
  3350	
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
  3361		 * offset 0. In order to align the objects we have to simply size
  3362		 * each object to conform to the alignment.
  3363		 */
  3364		size = ALIGN(size, s->align);
  3365		s->size = size;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--KsGdsel6WgEHnImy
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--KsGdsel6WgEHnImy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
