Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 800DB6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:17:20 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id v187so32635999wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:17:20 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id i7si18760972wjw.174.2015.12.10.05.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 05:17:19 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id v187so32635501wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:17:19 -0800 (PST)
Date: Thu, 10 Dec 2015 14:17:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/8] mm: memcontrol: move kmem accounting code to
 CONFIG_MEMCG
Message-ID: <20151210131718.GL19496@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 08-12-15 13:34:23, Johannes Weiner wrote:
> The cgroup2 memory controller will account important in-kernel memory
> consumers per default. Move all necessary components to CONFIG_MEMCG.

Hmm, that bloats the kernel also for users who are not using cgroup2
and have CONFIG_MEMCG_KMEM disabled.

This is the situation before this patch
   text    data     bss     dec     hex filename
 521342   97516   44312  663170   a1e82 mm/built-in.o.kmem
 513349   96299   43960  653608   9f928 mm/built-in.o.nokmem

and after with CONFIG_MEMCG_KMEM=n

 521028   96556   44312  661896   a1988 mm/built-in.o

we are basically back to CONFIG_MEMCG_KMEM=y. This sounds like a wastage
to me. Do we really need this?

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
