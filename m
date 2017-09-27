Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE28E6B025F
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:48:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so21624377pfj.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 00:48:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n127si959370pga.752.2017.09.27.00.48.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 00:48:38 -0700 (PDT)
Date: Wed, 27 Sep 2017 09:48:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
References: <20170921013310.31348-1-ying.huang@intel.com>
 <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
 <20170927050401.GA715@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927050401.GA715@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Wed 27-09-17 14:04:01, Minchan Kim wrote:
> On Tue, Sep 26, 2017 at 03:21:29PM +0200, Michal Hocko wrote:
> > On Thu 21-09-17 09:33:10, Huang, Ying wrote:
> > > From: Huang Ying <ying.huang@intel.com>
> > > 
> > > This patch adds a new Kconfig option VMA_SWAP_READAHEAD and wraps VMA
> > > based swap readahead code inside #ifdef CONFIG_VMA_SWAP_READAHEAD/#endif.
> > > This is more friendly for tiny kernels.
> > 
> > How (much)?
> > 
> > > And as pointed to by Minchan
> > > Kim, give people who want to disable the swap readahead an opportunity
> > > to notice the changes to the swap readahead algorithm and the
> > > corresponding knobs.
> > 
> > Why would anyone want that?
> > 
> > Please note that adding new config options make the already complicated
> > config space even more problematic so there should be a good reason to
> > add one. Please make sure your justification is clear on why this is
> > worth the future maintenance and configurability burden.
> 
> The problem is users have disabled swap readahead by echo 0 > /proc/sys/
> vm/page-cluster are regressed by this new interface /sys/kernel/mm/swap/
> vma_ra_max_order. Because for disabling readahead completely, they should
> disable vma_ra_max_order as well as page-cluster from now on.
> 
> So, goal of new config to notice new feature to admins so they can be aware
> of new konb vma_ra_max_order as well as page-cluster.
> I canont think other better idea to preventing such regression.
> 
> http://lkml.kernel.org/r/%3C20170913014019.GB29422@bbox%3E

So, how are you going to configure this when you do not know whether
zram will be used? In other words what should e.g. distribution set this
to?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
