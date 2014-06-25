Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 47D476B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 07:30:38 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id z6so1048090yhz.14
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 04:30:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j15si4880999yhh.23.2014.06.25.04.30.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 04:30:37 -0700 (PDT)
Message-ID: <53AAB2D3.2050809@oracle.com>
Date: Wed, 25 Jun 2014 19:30:27 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion
 of macro 'min'
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com> <20140625100213.GA1866@localhost>
In-Reply-To: <20140625100213.GA1866@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


On 06/25/2014 18:02 PM, Fengguang Wu wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   30404ddcb1872c8a571fa0889935ff65677e4c78
> commit: aef93cafef35b8830fc973be43f0745f9c16eff4 [156/212] binfmt_elf.c: use get_random_int() to fix entropy depleting
> config: make ARCH=mn10300 asb2364_defconfig
> 
> All warnings:
> 
>    In file included from include/asm-generic/bug.h:13:0,
>                     from arch/mn10300/include/asm/bug.h:35,
>                     from include/linux/bug.h:4,
>                     from include/linux/thread_info.h:11,
>                     from include/asm-generic/preempt.h:4,
>                     from arch/mn10300/include/generated/asm/preempt.h:1,
>                     from include/linux/preempt.h:18,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/seqlock.h:35,
>                     from include/linux/time.h:5,
>                     from include/linux/stat.h:18,
>                     from include/linux/module.h:10,
>                     from fs/binfmt_elf.c:12:
>    fs/binfmt_elf.c: In function 'get_atrandom_bytes':
>    include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
>      (void) (&_min1 == &_min2);  \
>                     ^
>>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
>       size_t chunk = min(nbytes, sizeof(random_variable));

I remember we have the same report on arch mn10300 about half a year ago, but the code
is correct. :)


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
