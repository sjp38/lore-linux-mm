Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id A4F506B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:30:52 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so7595949wes.13
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:30:52 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id y16si24977502wju.93.2014.06.17.09.30.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:30:51 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so6207349wib.5
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:30:50 -0700 (PDT)
Date: Tue, 17 Jun 2014 18:30:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 04/12] mm: memcontrol: retry reclaim for oom-disabled and
 __GFP_NOFAIL charges
Message-ID: <20140617163048.GC9572@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-5-git-send-email-hannes@cmpxchg.org>
 <20140617135344.GC19886@dhcp22.suse.cz>
 <20140617154527.GC7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617154527.GC7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-06-14 11:45:27, Johannes Weiner wrote:
> On Tue, Jun 17, 2014 at 03:53:44PM +0200, Michal Hocko wrote:
> > On Mon 16-06-14 15:54:24, Johannes Weiner wrote:
> > > There is no reason why oom-disabled and __GFP_NOFAIL charges should
> > > try to reclaim only once when every other charge tries several times
> > > before giving up.  Make them all retry the same number of times.
> > 
> > OK, this makes sense for oom-disabled and __GFP_NOFAIL but does it make
> > sense to do additional reclaim for tasks with fatal_signal_pending?
> > 
> > It is little bit unexpected, because we bypass if the condition happens
> > before the reclaim but then we ignore it.
> 
> "mm: memcontrol: rearrange charging fast path", moves the pending
> signal check inside the retry block, right before reclaim.

Right you are.

Acked-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
