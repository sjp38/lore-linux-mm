Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9ABD280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 04:29:51 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t67so154013033ywg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 01:29:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m129si222936ywb.237.2016.09.22.01.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 01:29:50 -0700 (PDT)
Date: Thu, 22 Sep 2016 10:29:46 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: mm/slub.o:undefined reference to `_GLOBAL_OFFSET_TABLE_'
Message-ID: <20160922102946.4712077b@redhat.com>
In-Reply-To: <201609221308.sGPlsAWm%fengguang.wu@intel.com>
References: <201609221308.sGPlsAWm%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, brouer@redhat.com

On Thu, 22 Sep 2016 13:50:21 +0800
kbuild test robot <fengguang.wu@intel.com> wrote:

> Hi Jesper,
> 
> FYI, the error/warning still remains.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   7d1e042314619115153a0f6f06e4552c09a50e13
> commit: d0ecd894e3d5f768a84403b34019c4a7daa05882 slub: optimize bulk slowpath free by detached freelist
> date:   10 months ago
> config: microblaze-allnoconfig (attached as .config)
> compiler: microblaze-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout d0ecd894e3d5f768a84403b34019c4a7daa05882
>         # save the attached .config to linux build tree
>         make.cross ARCH=microblaze 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/built-in.o: In function `__slab_free.isra.14':
> >> mm/slub.o:(.text+0x28d1c): undefined reference to `_GLOBAL_OFFSET_TABLE_'  
>    scripts/link-vmlinux.sh: line 52: 18051 Segmentation fault      ${LD} ${LDFLAGS} ${LDFLAGS_vmlinux} -o ${2} -T ${lds} ${KBUILD_VMLINUX_INIT} --start-group ${KBUILD_VMLINUX_MAIN} --end-group ${1}

Hi Fengguang,

I don't really understand if this is a real bug that I need to fix?

It looks like a linker problem, resulting in a "Segmentation fault" for your script...

The mentioned commit: d0ecd894e3d5f768a84 removes a call point to
__slab_free() and instead call slab_free().  It does not make sense to
my, why this results in a linker error on this ARCH=microblaze.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
