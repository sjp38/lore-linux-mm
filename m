Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 14AB96B009E
	for <linux-mm@kvack.org>; Sat, 22 Mar 2014 11:43:29 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so263658bkb.18
        for <linux-mm@kvack.org>; Sat, 22 Mar 2014 08:43:29 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id os9si3692474bkb.64.2014.03.22.08.43.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Mar 2014 08:43:28 -0700 (PDT)
Date: Sat, 22 Mar 2014 11:43:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] Per cgroup swap file support
Message-ID: <20140322154324.GK4407@cmpxchg.org>
References: <1395442234-7493-1-git-send-email-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395442234-7493-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com

Hello Yu!

On Fri, Mar 21, 2014 at 03:50:31PM -0700, Yu Zhao wrote:
> This series of patches adds support to configure a cgroup to swap to a
> particular file by using control file memory.swapfile.
> 
> A value of "default" in memory.swapfile indicates that this cgroup should
> use the default, system-wide, swap files. A value of "none" indicates that
> this cgroup should never swap. Other values are interpreted as the path
> to a private swap file that can only be used by the owner (and its children).
> 
> The swap file has to be created and swapon() has to be done on it with
> SWAP_FLAG_PRIVATE, before it can be used. This flag ensures that the swap
> file is private and does not get used by others.
> 
> Jamie Liu (1):
>   swap: do not store private swap files on swap_list
> 
> Suleiman Souhlal (2):
>   mm/swap: support per memory cgroup swapfiles
>   swap: Increase the maximum number of swap files to 8192.
> 
>  Documentation/cgroups/memory.txt  |  15 ++
>  arch/x86/include/asm/pgtable_64.h |  63 ++++++--
>  include/linux/memcontrol.h        |   2 +
>  include/linux/swap.h              |  45 +++---
>  mm/memcontrol.c                   |  76 ++++++++++
>  mm/memory.c                       |   3 +-
>  mm/shmem.c                        |   2 +-
>  mm/swap_state.c                   |   2 +-
>  mm/swapfile.c                     | 307 +++++++++++++++++++++++++++++++-------
>  mm/vmscan.c                       |   2 +-
>  10 files changed, 423 insertions(+), 94 deletions(-)

For feature patches like this, please include a rationale.  What is
this functionality good for, and who is going to use this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
