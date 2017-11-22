Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 555C56B027F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:37:10 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 72so8056637oik.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:37:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h195sor5667464oib.243.2017.11.22.13.37.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:37:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201711230046.iK2mFk89%fengguang.wu@intel.com>
References: <201711230046.iK2mFk89%fengguang.wu@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 22 Nov 2017 13:37:08 -0800
Message-ID: <CAPcyv4jspX-_a_0Pvw2TKgn6Op0h=Yq5EMi-1xvHDeDDJ_Xn-g@mail.gmail.com>
Subject: Re: [linux-next:master 13808/14071] arch/arm/include/asm/pgtable-3level.h:228:25:
 note: in expansion of macro 'pmd_write'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Nov 22, 2017 at 8:44 AM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   aa1fbe633d3034f9f838ff13387af04771e68e31
> commit: 5292abe86ee6b74a475d33d38bf5a266dacece0b [13808/14071] mm: fix device-dax pud write-faults triggered by get_user_pages()
> config: arm-axm55xx_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 5292abe86ee6b74a475d33d38bf5a266dacece0b
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from arch/arm/include/asm/pgtable.h:32:0,
>                     from include/linux/memremap.h:8,
>                     from include/linux/mm.h:27,
>                     from arch/arm/kernel/asm-offsets.c:15:
>>> arch/arm/include/asm/pgtable-3level.h:212:32: error: expected identifier or '(' before '!' token
>     #define pmd_isclear(pmd, val) (!(pmd_val(pmd) & (val)))
>                                    ^
>>> arch/arm/include/asm/pgtable-3level.h:225:26: note: in expansion of macro 'pmd_isclear'
>     #define pmd_write(pmd)  (pmd_isclear((pmd), L_PMD_SECT_RDONLY))
>                              ^~~~~~~~~~~
>>> arch/arm/include/asm/pgtable-3level.h:228:25: note: in expansion of macro 'pmd_write'
>     #define pud_write(pud)  pmd_write(__pmd(pud_val(pud)))
>                             ^~~~~~~~~
>    include/asm-generic/pgtable.h:817:19: note: in expansion of macro 'pud_write'
>     static inline int pud_write(pud_t pud)
>                       ^~~~~~~~~
>    make[2]: *** [arch/arm/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2

The build succeeds for me when this commit is based on top of mainline
at commit:

    a3841f94c7ec Merge tag 'libnvdimm-for-4.15' of
git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm

...so something in -next causes this to fail. I'll take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
