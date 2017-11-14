Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A74416B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 02:01:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id f9so10612824wra.2
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 23:01:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t13si1981948eda.261.2017.11.13.23.01.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 23:01:46 -0800 (PST)
Date: Tue, 14 Nov 2017 08:01:44 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm:master 180/303] arch/tile/kernel/setup.c:222:2: warning:
 the address of 'isolnodes' will always evaluate as 'true'
Message-ID: <20171114070144.up5kyh3zxb5ajdlj@dhcp22.suse.cz>
References: <201711111502.llJQ6zva%fengguang.wu@intel.com>
 <20171113161026.74c7931ba0f1cf378c27b928@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171113161026.74c7931ba0f1cf378c27b928@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon 13-11-17 16:10:26, Andrew Morton wrote:
> On Sat, 11 Nov 2017 15:49:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   21c4efa7694b072dddce68082e16156f24e1c1f0
> > commit: 224aa5f4017811570da4d0a332d9791da07b2fc7 [180/303] mm: simplify nodemask printing
> > config: tile-tilegx_defconfig (attached as .config)
> > compiler: tilegx-linux-gcc (GCC) 4.6.2
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 224aa5f4017811570da4d0a332d9791da07b2fc7
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=tile 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    arch/tile/kernel/setup.c: In function 'setup_isolnodes':
> > >> arch/tile/kernel/setup.c:222:2: warning: the address of 'isolnodes' will always evaluate as 'true' [-Waddress]
> > >> arch/tile/kernel/setup.c:222:2: warning: the address of 'isolnodes' will always evaluate as 'true' [-Waddress]
> > 
> > vim +222 arch/tile/kernel/setup.c
> > 
> > 77f8c740 Chris Metcalf 2013-08-06  216  
> > 867e359b Chris Metcalf 2010-05-28  217  static int __init setup_isolnodes(char *str)
> > 867e359b Chris Metcalf 2010-05-28  218  {
> > 867e359b Chris Metcalf 2010-05-28  219  	if (str == NULL || nodelist_parse(str, isolnodes) != 0)
> > 867e359b Chris Metcalf 2010-05-28  220  		return -EINVAL;
> > 867e359b Chris Metcalf 2010-05-28  221  
> > 839b2680 Tejun Heo     2015-02-13 @222  	pr_info("Set isolnodes value to '%*pbl'\n",
> > 839b2680 Tejun Heo     2015-02-13  223  		nodemask_pr_args(&isolnodes));
> > 867e359b Chris Metcalf 2010-05-28  224  	return 0;
> > 867e359b Chris Metcalf 2010-05-28  225  }
> > 867e359b Chris Metcalf 2010-05-28  226  early_param("isolnodes", setup_isolnodes);
> > 867e359b Chris Metcalf 2010-05-28  227  
> 
> Well that's irritating.  Maybe we can suppress it with some mess
> involving builtin_constant_p?

http://lkml.kernel.org/r/CAK8P3a36vx6fnXz=QWxqpCb3TC2XZeKLe3Or7Wvrac5=C3RaxA@mail.gmail.com
?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
