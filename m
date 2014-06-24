Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 946596B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 02:23:48 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so6821676pad.40
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 23:23:48 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ew3si24861168pac.229.2014.06.23.23.23.46
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 23:23:47 -0700 (PDT)
From: =?ks_c_5601-1987?B?sejB2Lz2?= <iamjoonsoo.kim@lge.com>
References: <53a8fd43.3YaWacNnJ4rMjQ6L%fengguang.wu@intel.com>
In-Reply-To: <53a8fd43.3YaWacNnJ4rMjQ6L%fengguang.wu@intel.com>
Subject: RE: [next:master 103/212] make[2]: *** No rule to make target `arch/powerpc/kvm/book3s_hv_cma.o', needed by `arch/powerpc/kvm/built-in.o'.
Date: Tue, 24 Jun 2014 15:23:45 +0900
Message-ID: <005c01cf8f74$da4866b0$8ed93410$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'kbuild test robot' <fengguang.wu@intel.com>
Cc: 'Linux Memory Management List' <linux-mm@kvack.org>, 'Andrew Morton' <akpm@linux-foundation.org>, kbuild-all@01.org



> -----Original Message-----
> From: kbuild test robot [mailto:fengguang.wu@intel.com]
> Sent: Tuesday, June 24, 2014 1:24 PM
> To: Joonsoo Kim
> Cc: Linux Memory Management List; Andrew Morton; kbuild-all@01.org
> Subject: [next:master 103/212] make[2]: *** No rule to make target
> `arch/powerpc/kvm/book3s_hv_cma.o', needed by `arch/powerpc/kvm/built-
> in.o'.
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> master
> head:   58ae500a03a6bf68eee323c342431bfdd3f460b6
> commit: e58e263e5254df63f3997192322220748e4f6223 [103/212] PPC, KVM, CMA:
> use general CMA reserved area management framework
> config: make ARCH=powerpc ppc64_defconfig
> 
> All error/warnings:
> 
> >> make[2]: *** No rule to make target `arch/powerpc/kvm/book3s_hv_cma.o',
> needed by `arch/powerpc/kvm/built-in.o'.
>    make[2]: Target `__build' not remade because of errors.

Thanks for reporting.
Here goes trivial fix!

-------------->8----------------------
