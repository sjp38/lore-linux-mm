Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19C976B038C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:57:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f21so304792520pgi.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:57:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h5si814375pln.273.2017.03.13.08.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:57:57 -0700 (PDT)
Subject: Re: arch/x86/include/asm/pgtable.h:888:2: error: implicit declaration
 of function 'native_pud_clear'
References: <201703120656.zGxXeJer%fengguang.wu@intel.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <9d16b438-0b64-2292-7de3-1b8daebe621e@intel.com>
Date: Mon, 13 Mar 2017 08:57:54 -0700
MIME-Version: 1.0
In-Reply-To: <201703120656.zGxXeJer%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Fengguang,
I don't believe Andrew has picked up this patch yet:
http://marc.info/?l=linux-mm&m=148883870428812&w=2

Unless you are seeing issues with that patch.

On 03/11/2017 03:55 PM, kbuild test robot wrote:
> Hi Matthew,
> 
> FYI, the error/warning still remains.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   84c37c168c0e49a412d7021cda3183a72adac0d0
> commit: a00cc7d9dd93d66a3fb83fc52aa57a4bec51c517 mm, x86: add support for PUD-sized transparent hugepages
> date:   2 weeks ago
> config: i386-randconfig-a0-201711 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout a00cc7d9dd93d66a3fb83fc52aa57a4bec51c517
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/mm.h:68:0,
>                     from include/linux/suspend.h:8,
>                     from arch/x86/kernel/asm-offsets.c:12:
>    arch/x86/include/asm/pgtable.h: In function 'native_local_pudp_get_and_clear':
>>> arch/x86/include/asm/pgtable.h:888:2: error: implicit declaration of function 'native_pud_clear' [-Werror=implicit-function-declaration]
>      native_pud_clear(pudp);
>      ^~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors
>    make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
> 
> vim +/native_pud_clear +888 arch/x86/include/asm/pgtable.h
> 
>    882	}
>    883	
>    884	static inline pud_t native_local_pudp_get_and_clear(pud_t *pudp)
>    885	{
>    886		pud_t res = *pudp;
>    887	
>  > 888		native_pud_clear(pudp);
>    889		return res;
>    890	}
>    891	
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
