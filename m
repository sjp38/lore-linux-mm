Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF6B6B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:14:21 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u48so954597wrc.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:14:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l91si206415wrc.30.2017.03.07.06.14.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 06:14:19 -0800 (PST)
Date: Tue, 7 Mar 2017 15:14:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-4.9 2/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170307141417.GK28642@dhcp22.suse.cz>
References: <20170228151108.20853-1-mhocko@kernel.org>
 <20170228151108.20853-3-mhocko@kernel.org>
 <CAE8gLhkH4W6ZvMMCe7s-nTdGQBHg1HOj_jsfZWHimH6ZXzGWQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE8gLhkH4W6ZvMMCe7s-nTdGQBHg1HOj_jsfZWHimH6ZXzGWQA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: MegaBrutal <megabrutal@gmail.com>
Cc: Stable tree <stable@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

On Mon 06-03-17 19:00:00, MegaBrutal wrote:
> Hi Michal,
> 
> I'm over a very long kernel bisection, and if I made no mistake in
> testing commits, this patch fixes a kernel bug which affects my HP
> Compaq dc5800 machine with 32 bit Ubuntu OS.
> 
> The bug manifests itself with "NMI watchdog: BUG: soft lockup - CPU#0
> stuck for 23s! [kswapd0:38]" messages in 4.8 kernels, and "page
> allocation stalls for 47608ms, order:1,
> mode:0x17000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK)" in 4.10 kernels up
> to this commit.

This is really hard to say without seeing the traces.
 
> Michal, can you confirm that this patch may fix issues like the ones I
> encountered? If so, I'll try to get the Ubuntu kernel staff to
> backport this commit to Yakkety's 4.8 kernel. On the other hand, I
> can't seem to be able to backport this commit to 4.8 with "git
> cherry-pick", so maybe I need to wait for your tweaks you mentioned.

The backport from 4.9 to 4.8 shouldn't be very complicated I believe.
 
> Anyway, thank you very much for the fix!

Good to hear the patch helped you though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
