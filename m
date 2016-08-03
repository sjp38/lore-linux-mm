Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 259DF6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 22:09:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so370074238pfg.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 19:09:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lv5si6032113pab.152.2016.08.02.19.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 19:09:58 -0700 (PDT)
Date: Tue, 2 Aug 2016 19:09:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 138/210] drivers/gpu/drm/msm/msm_drv.c:781:19:
 error: 'q' undeclared here (not in a function)
Message-Id: <20160802190956.2c2ca13f8b5fb806d2179ebe@linux-foundation.org>
In-Reply-To: <201608031019.rRyFjE6p%fengguang.wu@intel.com>
References: <201608031019.rRyFjE6p%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, mmotm auto import <mm-commits@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 3 Aug 2016 10:01:36 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   572b7c98f12bd2213553be42cc5c2cbc5698f5c3
> commit: 4cceb4d7a297fcaec3527e355e6881850fc50ed3 [138/210] linux-next-git-rejects
> config: arm64-defconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 4cceb4d7a297fcaec3527e355e6881850fc50ed3
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm64 
> 
> All error/warnings (new ones prefixed by >>):
> 
> >> drivers/gpu/drm/msm/msm_drv.c:781:19: error: 'q' undeclared here (not in a function)
>         DRIVER_PRIME |q

That's me being a twit.  This will go away in the next linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
