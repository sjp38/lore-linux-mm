Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCE66B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 22:46:22 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wm4so2010975obc.31
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 19:46:21 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id ws6si1438885oeb.58.2014.03.05.19.46.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 19:46:21 -0800 (PST)
Message-ID: <1394077577.29724.19.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [mmotm:master 188/471] include/linux/swap.h:33:16: error:
 dereferencing pointer to incomplete type
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 05 Mar 2014 19:46:17 -0800
In-Reply-To: <5317ea88.Pvq6lNAdz5mv4Fdd%fengguang.wu@intel.com>
References: <5317ea88.Pvq6lNAdz5mv4Fdd%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, 2014-03-06 at 11:24 +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
> commit: 88a76abced8c721ac726ea6a273ed0389b1c5ff4 [188/471] mm: per-thread vma caching
> config: make ARCH=sparc defconfig
> 
> All error/warnings:
> 
>    In file included from arch/sparc/include/asm/pgtable_32.h:17:0,
>                     from arch/sparc/include/asm/pgtable.h:6,
>                     from include/linux/mm.h:51,
>                     from include/linux/vmacache.h:4,
>                     from include/linux/sched.h:26,
>                     from arch/sparc/kernel/asm-offsets.c:13:
>    include/linux/swap.h: In function 'current_is_kswapd':
> >> include/linux/swap.h:33:16: error: dereferencing pointer to incomplete type
> >> include/linux/swap.h:33:26: error: 'PF_KSWAPD' undeclared (first use in this function)
>    include/linux/swap.h:33:26: note: each undeclared identifier is reported only once for each function it appears in
>    make[2]: *** [arch/sparc/kernel/asm-offsets.s] Error 1
>    make[2]: Target `__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target `prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
> 
> vim +33 include/linux/swap.h

I knew something like this was gonna happen with the whole header file
thing. Andrew, would you prefer getting rid of vmacache.h and just
sticking the contents in mm.h? I was hoping not to do that, but if it
causes a lot of pain then the hell with it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
