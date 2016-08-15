Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C83976B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 07:29:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so113517633pfg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 04:29:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a9si26311635pao.113.2016.08.15.04.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 04:29:43 -0700 (PDT)
Date: Mon, 15 Aug 2016 13:29:52 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [linux-stable-rc:linux-4.4.y 1992/2009] mm/slab_common.c:524:37:
 warning: format '%d' expects argument of type 'int', but argument 4 has type
 'u64 {aka long long unsigned int}'
Message-ID: <20160815112952.GA18672@kroah.com>
References: <201608150636.0E2XOWl9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201608150636.0E2XOWl9%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>

On Mon, Aug 15, 2016 at 06:47:38AM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.4.y
> head:   a44a0226e48694a1263c10fc528b76205127734e
> commit: 39a78b1ec7dea2d4bae32b3a7326686f2822003a [1992/2009] mm: memcontrol: fix cgroup creation failure after many small jobs
> config: arm64-defconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 39a78b1ec7dea2d4bae32b3a7326686f2822003a
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm64 
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/slab_common.c: In function 'memcg_create_kmem_cache':
> >> mm/slab_common.c:524:37: warning: format '%d' expects argument of type 'int', but argument 4 has type 'u64 {aka long long unsigned int}' [-Wformat=]
>      cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
>                                         ^

I've now fixed this up, the backport missed this.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
