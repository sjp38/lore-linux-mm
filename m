Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91AA88E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 03:05:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a23-v6so6115784pfo.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 00:05:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r1-v6si26467164pls.131.2018.09.21.00.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 00:05:32 -0700 (PDT)
Date: Fri, 21 Sep 2018 15:03:19 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v8 01/20] kasan, mm: change hooks signatures
Message-ID: <201809211535.aQeO07A4%fengguang.wu@intel.com>
References: <8b30f2d3e325de843f892e32f076fe9cc726191d.1537383101.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Content-Disposition: inline
In-Reply-To: <8b30f2d3e325de843f892e32f076fe9cc726191d.1537383101.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: kbuild-all@01.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrey,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.19-rc4 next-20180919]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Andrey-Konovalov/kasan-add-software-tag-based-mode-for-arm64/20180920-172444
config: microblaze-mmu_defconfig (attached as .config)
compiler: microblaze-linux-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=microblaze 

All errors (new ones prefixed by >>):

   In file included from include/linux/slab.h:129,
                    from include/linux/irq.h:21,
                    from include/asm-generic/hardirq.h:13,
                    from ./arch/microblaze/include/generated/asm/hardirq.h:1,
                    from include/linux/hardirq.h:9,
                    from include/linux/interrupt.h:11,
                    from include/linux/kernel_stat.h:9,
                    from arch/microblaze/kernel/asm-offsets.c:14:
   include/linux/kasan.h: In function 'kasan_init_slab_obj':
>> include/linux/kasan.h:111:9: error: 'ptr' undeclared (first use in this function); did you mean 'qstr'?
     return ptr;
            ^~~
            qstr
   include/linux/kasan.h:111:9: note: each undeclared identifier is reported only once for each function it appears in
   make[2]: *** [arch/microblaze/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +111 include/linux/kasan.h

   102	
   103	static inline void kasan_poison_slab(struct page *page) {}
   104	static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
   105						void *object) {}
   106	static inline void kasan_poison_object_data(struct kmem_cache *cache,
   107						void *object) {}
   108	static inline void *kasan_init_slab_obj(struct kmem_cache *cache,
   109					const void *object)
   110	{
 > 111		return ptr;
   112	}
   113	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--jI8keyz6grp/JLjh
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
bjbNyKf+B4UtzE/XygAA

--jI8keyz6grp/JLjh--
