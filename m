Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 127CF6B0082
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 12:29:00 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so11021716pbc.16
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 09:28:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ev1si7804625pbb.208.2014.04.16.09.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Apr 2014 09:28:59 -0700 (PDT)
Message-ID: <534EAFC9.8010702@codeaurora.org>
Date: Wed, 16 Apr 2014 09:28:57 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [next:master 103/113] arch/powerpc/platforms/52xx/efika.c:210:2:
 error: 'ISA_DMA_THRESHOLD' undeclared
References: <534e3806.dEDbrOl+B+miaF+8%fengguang.wu@intel.com>
In-Reply-To: <534e3806.dEDbrOl+B+miaF+8%fengguang.wu@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On 4/16/2014 12:57 AM, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   2db08cc65391d73dc8cbcaefdb55c42a774d9e1a
> commit: ff35bd54456e18878c361a8a2deeb41c9688458f [103/113] lib/scatterlist: make ARCH_HAS_SG_CHAIN an actual Kconfig
> config: make ARCH=powerpc ppc6xx_defconfig
> 
> All error/warnings:
> 
>    arch/powerpc/platforms/52xx/efika.c: In function 'efika_probe':
>>> arch/powerpc/platforms/52xx/efika.c:210:2: error: 'ISA_DMA_THRESHOLD' undeclared (first use in this function)
>      ISA_DMA_THRESHOLD = ~0L;
>      ^
>    arch/powerpc/platforms/52xx/efika.c:210:2: note: each undeclared identifier is reported only once for each function it appears in
>>> arch/powerpc/platforms/52xx/efika.c:211:2: error: 'DMA_MODE_READ' undeclared (first use in this function)
>      DMA_MODE_READ = 0x44;
>      ^
>>> arch/powerpc/platforms/52xx/efika.c:212:2: error: 'DMA_MODE_WRITE' undeclared (first use in this function)
>      DMA_MODE_WRITE = 0x48;
>      ^

Another fixup needed (should cover errors from other generated config as well)

---- 8< ----
