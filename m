Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7F86B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 07:26:31 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so3064998eek.34
        for <linux-mm@kvack.org>; Fri, 02 May 2014 04:26:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l41si1347481eef.218.2014.05.02.04.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 04:26:29 -0700 (PDT)
Date: Fri, 2 May 2014 13:26:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/9] mm: memcontrol: naturalize charge lifetime
Message-ID: <20140502112627.GG3446@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:34, Johannes Weiner wrote:
[...]
>  Documentation/cgroups/memcg_test.txt |  160 +--
>  include/linux/memcontrol.h           |   94 +-
>  include/linux/page_cgroup.h          |   43 +-
>  include/linux/swap.h                 |   15 +-
>  kernel/events/uprobes.c              |    1 +
>  mm/filemap.c                         |   13 +-
>  mm/huge_memory.c                     |   51 +-
>  mm/memcontrol.c                      | 1724 ++++++++++++--------------------
>  mm/memory.c                          |   41 +-
>  mm/migrate.c                         |   46 +-
>  mm/rmap.c                            |    6 -
>  mm/shmem.c                           |   28 +-
>  mm/swap.c                            |   22 +
>  mm/swap_state.c                      |    8 +-
>  mm/swapfile.c                        |   21 +-
>  mm/truncate.c                        |    1 -
>  mm/vmscan.c                          |    9 +-
>  mm/zswap.c                           |    2 +-
>  18 files changed, 833 insertions(+), 1452 deletions(-)

Impressive! I will get through the series but it will take some time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
