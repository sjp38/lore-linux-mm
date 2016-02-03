Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB946B0256
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 11:24:18 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id m1so17882772lfg.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 08:24:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 134si4490585lfz.13.2016.02.03.08.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 08:24:17 -0800 (PST)
Date: Wed, 3 Feb 2016 11:24:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/workingset: do not forget to unlock page
Message-ID: <20160203162400.GB10440@cmpxchg.org>
References: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20160203104136.GA517@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160203104136.GA517@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Feb 03, 2016 at 07:41:36PM +0900, Sergey Senozhatsky wrote:
> From 1d6315221f2f81c53c99f9980158f8ae49dbd582 Mon Sep 17 00:00:00 2001
> From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Date: Wed, 3 Feb 2016 18:49:16 +0900
> Subject: [PATCH] mm/workingset: do not forget to unlock_page in workingset_activation
> 
> Do not return from workingset_activation() with locked rcu and page.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks Sergey. Even though I wrote this function, my brain must have
gone "it can't be locking anything when it returns NULL, right?" It's
a dumb interface. Luckily, that's fixed with follow-up patches in -mm.

As for this one:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Fixes: mm: workingset: per-cgroup cache thrash detection

Andrew, can you please fold this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
