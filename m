Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 445646B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:39:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g66so2925304pfj.11
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 01:39:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5-v6si2943472pls.740.2018.03.15.01.39.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 01:39:24 -0700 (PDT)
Date: Thu, 15 Mar 2018 09:39:20 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:since-4.15 382/386] arch/m68k/mm/init.c:125:0: warning:
 "UL" redefined
Message-ID: <20180315083920.GY23100@dhcp22.suse.cz>
References: <201803142315.LTV2xdYr%fengguang.wu@intel.com>
 <20180314134445.61e26e6038e5c565f1438a9b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314134445.61e26e6038e5c565f1438a9b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, kbuild-all@01.org, linux-mm@kvack.org

On Wed 14-03-18 13:44:45, Andrew Morton wrote:
> On Wed, 14 Mar 2018 23:20:21 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.15
> > head:   5c3f7a041df707417532dd64b1d71fc29b24c0fe
> > commit: 145e9c14cca497b2d02f9edcf9307aad5946172f [382/386] linux/const.h: move UL() macro to include/linux/const.h
> > config: m68k-sun3_defconfig (attached as .config)
> > compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 145e9c14cca497b2d02f9edcf9307aad5946172f
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=m68k 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    arch/m68k/mm/init.c: In function 'print_memmap':
> > >> arch/m68k/mm/init.c:125:0: warning: "UL" redefined
> >     #define UL(x) ((unsigned long) (x))
> >     
> >    In file included from include/linux/list.h:8:0,
> >                     from include/linux/module.h:9,
> >                     from arch/m68k/mm/init.c:11:
> >    include/linux/const.h:6:0: note: this is the location of the previous definition
> >     #define UL(x)  (_UL(x))
> 
> That's OK - an unrelated patch in linux-next.patch removes that
> #define.
> 

I have cherry-picked 445420c31cbba4a218b432bece0b500b6c4f9d63 into my
mmotm git tree. Thanks for pointing that out.

-- 
Michal Hocko
SUSE Labs
