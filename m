Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 973C06B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 07:09:23 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id c80so18138146lfh.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 04:09:23 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 68si8011127ljj.12.2017.05.01.04.09.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 04:09:21 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id x72so12878154lfb.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 04:09:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201705011829.pgKWNzqt%fengguang.wu@intel.com>
References: <20170501063438.25237-3-bsingharora@gmail.com> <201705011829.pgKWNzqt%fengguang.wu@intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 1 May 2017 21:09:20 +1000
Message-ID: <CAKTCnznHZBL-rHEPiL45BRu0ydXpDPmkmENPCiXqq1Dx2+SiCA@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] powerpc/mm/book(e)(3s)/32: Add page table accounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Michael Ellerman <mpe@ellerman.id.au>, Scott Wood <oss@buserror.net>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>

On Mon, May 1, 2017 at 8:31 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Balbir,
>
> [auto build test ERROR on powerpc/next]
> [also build test ERROR on v4.11 next-20170428]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Balbir-Singh/powerpc-mm-book-e-3s-64-Add-page-table-accounting/20170501-143900
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git next
> config: powerpc-virtex5_defconfig (attached as .config)
> compiler: powerpc-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=powerpc
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from arch/powerpc/mm/mem.c:25:0:
>    arch/powerpc/include/asm/nohash/32/pgalloc.h: In function 'pgd_alloc':
>>> include/linux/gfp.h:240:20: error: passing argument 1 of 'pgtable_gfp_flags' makes pointer from integer without a cast [-Werror=int-conversion]
>     #define GFP_KERNEL (__GFP_RECLAIM | __GFP_IO | __GFP_FS)
>                        ^
>    arch/powerpc/include/asm/nohash/32/pgalloc.h:35:22: note: in expansion of macro 'GFP_KERNEL'
>        pgtable_gfp_flags(GFP_KERNEL));

That's a silly build error that escaped my build scripts, I'll send
out a better v3 with 32 bits fixed.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
