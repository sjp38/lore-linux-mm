Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 280D76B0253
	for <linux-mm@kvack.org>; Sat,  8 Aug 2015 04:31:07 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so68305075pac.3
        for <linux-mm@kvack.org>; Sat, 08 Aug 2015 01:31:06 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fk8si22761090pdb.228.2015.08.08.01.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Aug 2015 01:31:05 -0700 (PDT)
Date: Sat, 8 Aug 2015 11:30:55 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [linux-next:master 6277/6751] mm/page_idle.c:74:4: error:
 implicit declaration of function 'pte_unmap'
Message-ID: <20150808083055.GA15152@esperanza>
References: <201508072227.PBXmgcfg%fengguang.wu@intel.com>
 <20150807142622.b2de8f5e70f1224dfe9aa195@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150807142622.b2de8f5e70f1224dfe9aa195@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Aug 07, 2015 at 02:26:22PM -0700, Andrew Morton wrote:
> On Fri, 7 Aug 2015 22:24:33 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   e6455bc5b91f41f842f30465c9193320f0568707
> > commit: cbba4e22584984bffccd07e0801fd2b8ec1ecf5f [6277/6751] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap
> > config: blackfin-allmodconfig (attached as .config)
> > reproduce:
> >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >   chmod +x ~/bin/make.cross
> >   git checkout cbba4e22584984bffccd07e0801fd2b8ec1ecf5f
> >   # save the attached .config to linux build tree
> >   make.cross ARCH=blackfin 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    mm/page_idle.c: In function 'page_idle_clear_pte_refs_one':
> >    mm/page_idle.c:67:4: error: implicit declaration of function 'pmdp_test_and_clear_young' [-Werror=implicit-function-declaration]
> >    mm/page_idle.c:71:3: error: implicit declaration of function 'page_check_address' [-Werror=implicit-function-declaration]
> 
> Yeah.  This?
> 
...
>  config IDLE_PAGE_TRACKING
>  	bool "Enable idle page tracking"
> -	depends on SYSFS
> +	depends on SYSFS && MMU

Yes, that's it. Thank you.

>  	select PAGE_EXTENSION if !64BIT
>  	help
>  	  This feature allows to estimate the amount of user pages that have

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
