Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 053426B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:04:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m30so25021184pgn.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 22:04:07 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 1si6874619plj.222.2017.09.26.22.04.06
        for <linux-mm@kvack.org>;
        Tue, 26 Sep 2017 22:04:06 -0700 (PDT)
Date: Wed, 27 Sep 2017 14:04:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170927050401.GA715@bbox>
References: <20170921013310.31348-1-ying.huang@intel.com>
 <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Tue, Sep 26, 2017 at 03:21:29PM +0200, Michal Hocko wrote:
> On Thu 21-09-17 09:33:10, Huang, Ying wrote:
> > From: Huang Ying <ying.huang@intel.com>
> > 
> > This patch adds a new Kconfig option VMA_SWAP_READAHEAD and wraps VMA
> > based swap readahead code inside #ifdef CONFIG_VMA_SWAP_READAHEAD/#endif.
> > This is more friendly for tiny kernels.
> 
> How (much)?
> 
> > And as pointed to by Minchan
> > Kim, give people who want to disable the swap readahead an opportunity
> > to notice the changes to the swap readahead algorithm and the
> > corresponding knobs.
> 
> Why would anyone want that?
> 
> Please note that adding new config options make the already complicated
> config space even more problematic so there should be a good reason to
> add one. Please make sure your justification is clear on why this is
> worth the future maintenance and configurability burden.

The problem is users have disabled swap readahead by echo 0 > /proc/sys/
vm/page-cluster are regressed by this new interface /sys/kernel/mm/swap/
vma_ra_max_order. Because for disabling readahead completely, they should
disable vma_ra_max_order as well as page-cluster from now on.

So, goal of new config to notice new feature to admins so they can be aware
of new konb vma_ra_max_order as well as page-cluster.
I canont think other better idea to preventing such regression.

http://lkml.kernel.org/r/%3C20170913014019.GB29422@bbox%3E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
