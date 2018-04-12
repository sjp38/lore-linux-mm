Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEF796B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:13:48 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so3896742plb.16
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:13:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10-v6si3475905plt.616.2018.04.12.07.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 07:13:47 -0700 (PDT)
Date: Thu, 12 Apr 2018 16:13:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHSET] mm, memcontrol: Implement memory.swap.events
Message-ID: <20180412141345.GH23400@dhcp22.suse.cz>
References: <20180324165127.701194-1-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180324165127.701194-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi Tejun,
sorry for the late response. Are you plannig to repost?

On Sat 24-03-18 09:51:25, Tejun Heo wrote:
> Hello,
> 
> This patchset implements memory.swap.events which contains max and
> fail events so that userland can monitor and respond to swap running
> out.  It contains the following two patches.
> 
>  0001-mm-memcontrol-Move-swap-charge-handling-into-get_swa.patch
>  0002-mm-memcontrol-Implement-memory.swap.events.patch
> 
> This patchset is on top of the "cgroup/for-4.17: Make cgroup_rstat
> available to controllers" patchset[1] and "mm, memcontrol: Make
> cgroup_rstat available to controllers" patchset[2] and also available
> in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-swap.events
> 
> diffstat follows.
> 
>  Documentation/cgroup-v2.txt |   16 ++++++++++++++++
>  include/linux/memcontrol.h  |    5 +++++
>  mm/memcontrol.c             |   25 +++++++++++++++++++++++++
>  mm/shmem.c                  |    4 ----
>  mm/swap_slots.c             |   10 +++++++---
>  mm/swap_state.c             |    3 ---
>  6 files changed, 53 insertions(+), 10 deletions(-)
> 
> Thanks.
> 
> --
> tejun
> 
> [1] http://lkml.kernel.org/r/20180323231313.1254142-1-tj@kernel.org
> [2] http://lkml.kernel.org/r/20180324160901.512135-1-tj@kernel.org

-- 
Michal Hocko
SUSE Labs
