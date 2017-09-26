Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97DB06B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:21:34 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v109so12604313wrc.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:21:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j41si7462781wra.430.2017.09.26.06.21.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:21:31 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:21:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
References: <20170921013310.31348-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921013310.31348-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Thu 21-09-17 09:33:10, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patch adds a new Kconfig option VMA_SWAP_READAHEAD and wraps VMA
> based swap readahead code inside #ifdef CONFIG_VMA_SWAP_READAHEAD/#endif.
> This is more friendly for tiny kernels.

How (much)?

> And as pointed to by Minchan
> Kim, give people who want to disable the swap readahead an opportunity
> to notice the changes to the swap readahead algorithm and the
> corresponding knobs.

Why would anyone want that?

Please note that adding new config options make the already complicated
config space even more problematic so there should be a good reason to
add one. Please make sure your justification is clear on why this is
worth the future maintenance and configurability burden.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
