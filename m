Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 220EB6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:45:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r83so22569579pfj.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:45:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h69si7376339pge.187.2017.09.27.03.45.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 03:45:44 -0700 (PDT)
Date: Wed, 27 Sep 2017 12:45:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
Message-ID: <20170927104537.r42javxhnyqlxnqm@dhcp22.suse.cz>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 27-09-17 08:53:35, Yang Shi wrote:
> Kernel may panic when oom happens without killable process sometimes it
> is caused by huge unreclaimable slabs used by kernel.
> 
> Although kdump could help debug such problem, however, kdump is not
> available on all architectures and it might be malfunction sometime.
> And, since kernel already panic it is worthy capturing such information
> in dmesg to aid touble shooting.
> 
> Print out unreclaimable slab info (used size and total size) which
> actual memory usage is not zero (num_objs * size != 0) when:
>   - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
>   - panic_on_oom is set or no killable process

OK, this is better but I do not see why this should be tunable via proc.
Can we start with simple NR_SLAB_UNRECLAIMABLE > LRU_PAGES and place it
into dump_header so that we get the report also during regular OOM?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
