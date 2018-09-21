Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFF788E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:13:15 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w23-v6so20316475iob.18
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 05:13:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u21-v6sor15923383iof.177.2018.09.21.05.13.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 05:13:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201809211218.10PA6RGy%fengguang.wu@intel.com>
References: <8b30f2d3e325de843f892e32f076fe9cc726191d.1537383101.git.andreyknvl@google.com>
 <201809211218.10PA6RGy%fengguang.wu@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 21 Sep 2018 14:13:13 +0200
Message-ID: <CAAeHK+z7s2mO4nn-86n+sNTkdOVpFRnAo05fO48S88qKpj_xeQ@mail.gmail.com>
Subject: Re: [PATCH v8 01/20] kasan, mm: change hooks signatures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Fri, Sep 21, 2018 at 6:05 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Andrey,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.19-rc4 next-20180919]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Andrey-Konovalov/kasan-add-software-tag-based-mode-for-arm64/20180920-172444
> config: x86_64-randconfig-x013-201837 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    In file included from include/linux/slab.h:129:0,
>                     from include/linux/crypto.h:24,
>                     from arch/x86/kernel/asm-offsets.c:9:
>    include/linux/kasan.h: In function 'kasan_init_slab_obj':
>>> include/linux/kasan.h:111:9: error: 'ptr' undeclared (first use in this function)
>      return ptr;
>             ^~~

Right, will fix in v9.

>    include/linux/kasan.h:111:9: note: each undeclared identifier is reported only once for each function it appears in
>    make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
>
> vim +/ptr +111 include/linux/kasan.h
>
>    102
>    103  static inline void kasan_poison_slab(struct page *page) {}
>    104  static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
>    105                                          void *object) {}
>    106  static inline void kasan_poison_object_data(struct kmem_cache *cache,
>    107                                          void *object) {}
>    108  static inline void *kasan_init_slab_obj(struct kmem_cache *cache,
>    109                                  const void *object)
>    110  {
>  > 111          return ptr;
>    112  }
>    113
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/201809211218.10PA6RGy%25fengguang.wu%40intel.com.
> For more options, visit https://groups.google.com/d/optout.
