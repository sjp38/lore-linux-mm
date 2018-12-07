Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28AF08E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:12:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so3569898pgj.21
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:12:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m30si4331322pff.158.2018.12.07.15.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 15:12:36 -0800 (PST)
Date: Fri, 7 Dec 2018 15:12:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 128/293] kernel/sysctl.o:undefined reference to
 `fragment_stall_order_sysctl_handler'
Message-Id: <20181207151234.688d0dbf0e654c7b423fcca2@linux-foundation.org>
In-Reply-To: <20181205112001.GD31508@suse.de>
References: <201812051704.QejGRMmV%fengguang.wu@intel.com>
	<20181205112001.GD31508@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 5 Dec 2018 11:20:01 +0000 Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Dec 05, 2018 at 05:12:06PM +0800, kbuild test robot wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   7072a0ce81c613d27563eed5425727d1d8791f58
> > commit: e3e68607541c60671eb3499a2c064d2f71626da4 [128/293] mm: stall movable allocations until kswapd progresses during serious external fragmentation event
> > config: c6x-evmc6678_defconfig (attached as .config)
> > compiler: c6x-elf-gcc (GCC) 8.1.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout e3e68607541c60671eb3499a2c064d2f71626da4
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=8.1.0 make.cross ARCH=c6x 
> > 
> > All errors (new ones prefixed by >>):
> > 
> 
> This appears to be some sort of glitch in Andrew's tree. It works in
> mmots and is broken in mmotm. The problem is that with mmotm, the
> fragment_stall_order_sysctl_handler handler has moved below
> sysctl_min_slab_ratio_sysctl_handler instead of below
> watermark_boost_factor_sysctl_handler where it belongs.
> 
> Now, while this could be fixed, in this specific instance I would prefer
> the patch be dropped entirely because there are some potential downsides
> that are potentially distracting and the supporting data is not strong
> enough too justify the potential downsides.
> 
> Andrew?

Well that was an easy fix ;)
