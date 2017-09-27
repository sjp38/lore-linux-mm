Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCECC6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:35:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r74so13713991wme.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:35:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18si8692367wra.107.2017.09.27.01.35.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:35:15 -0700 (PDT)
Date: Wed, 27 Sep 2017 10:35:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170927083512.dydqlqezh5polggb@dhcp22.suse.cz>
References: <20170921013310.31348-1-ying.huang@intel.com>
 <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
 <20170927050401.GA715@bbox>
 <20170927074835.37m4dclmew5ecli2@dhcp22.suse.cz>
 <20170927080432.GA1160@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927080432.GA1160@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Wed 27-09-17 17:04:32, Minchan Kim wrote:
> On Wed, Sep 27, 2017 at 09:48:35AM +0200, Michal Hocko wrote:
> > On Wed 27-09-17 14:04:01, Minchan Kim wrote:
[...]
> > > The problem is users have disabled swap readahead by echo 0 > /proc/sys/
> > > vm/page-cluster are regressed by this new interface /sys/kernel/mm/swap/
> > > vma_ra_max_order. Because for disabling readahead completely, they should
> > > disable vma_ra_max_order as well as page-cluster from now on.
> > > 
> > > So, goal of new config to notice new feature to admins so they can be aware
> > > of new konb vma_ra_max_order as well as page-cluster.
> > > I canont think other better idea to preventing such regression.
> > > 
> > > http://lkml.kernel.org/r/%3C20170913014019.GB29422@bbox%3E
> > 
> > So, how are you going to configure this when you do not know whether
> > zram will be used? In other words what should e.g. distribution set this
> > to?
> 
> I have no idea. Unfortunately, it depends on them. If they want to use
> zram as swap, they should fix the script. Surely, I don't like it.
> Instead, I wanted that page-cluster zeroing disables both virtual/pysical
> swap readahead not to break current userspace. However, Huang doesn't
> liek it.
> If you have better idea, please suggest.

I understand your frustration but config options are not there to bypass
proper design decisions. Why cannot we unconditionally disable all the
read ahead when zram is enabled?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
