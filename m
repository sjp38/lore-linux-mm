Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7296B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 08:45:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so47624427wmw.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 05:45:39 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id hb7si4688381wjd.57.2016.05.04.05.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 05:45:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so10028244wmw.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 05:45:37 -0700 (PDT)
Date: Wed, 4 May 2016 14:45:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
Message-ID: <20160504124535.GJ29978@dhcp22.suse.cz>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
 <1462309239.21143.6.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1462309239.21143.6.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue 03-05-16 14:00:39, Tim Chen wrote:
[...]
>  include/linux/swap.h |  29 ++-
>  mm/swap_state.c      | 253 +++++++++++++-----
>  mm/swapfile.c        | 215 +++++++++++++--
>  mm/vmscan.c          | 725 ++++++++++++++++++++++++++++++++++++++-------------
>  4 files changed, 945 insertions(+), 277 deletions(-)

This is rather large change for a normally rare path. We have been
trying to preserve the anonymous memory as much as possible and rather
push the page cache out. In fact swappiness is ignored most of the
time for the vast majority of workloads.

So this would help anonymous mostly workloads and I am really wondering
whether this is something worth bothering without further and deeper
rethinking of our current reclaim strategy. I fully realize that the
swap out sucks and that the new storage technologies might change the
way how we think about anonymous memory being so "special" wrt. disk
based caches but I would like to see a stronger use case than "we have
been playing with some artificial use case and it scales better"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
