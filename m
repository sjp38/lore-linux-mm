Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72D356B02C3
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 15:38:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z6so56351318pgc.13
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:38:55 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id i23si5466729pll.379.2017.06.04.12.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 12:38:54 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id 9so73233456pfj.1
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:38:54 -0700 (PDT)
Date: Sun, 4 Jun 2017 12:38:50 -0700
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] swap: cond_resched in swap_cgroup_prepare()
Message-ID: <20170604193850.GA15369@google.com>
References: <20170601195635.20744-1-yuzhao@google.com>
 <20170602081855.GE29840@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170602081855.GE29840@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 02, 2017 at 10:18:57AM +0200, Michal Hocko wrote:
> On Thu 01-06-17 12:56:35, Yu Zhao wrote:
> > Saw need_resched() warnings when swapping on large swapfile (TBs)
> > because page allocation in swap_cgroup_prepare() took too long.
> 
> Hmm, but the page allocator makes sure to cond_resched for sleeping
> allocations. I guess what you mean is something different. It is not the
> allocation which took too look but there are too many of them and none
> of them sleeps because there is enough memory and the allocator doesn't
> sleep in that case. Right?
> 
> > We already cond_resched when freeing page in swap_cgroup_swapoff().
> > Do the same for the page allocation.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> 
> The patch itself makes sense to me, the changelog could see some
> clarification but other than that
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks, I'll clarify the problem in the commit message and resend the
patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
