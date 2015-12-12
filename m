Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 084726B0257
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 11:39:37 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so80990492pac.1
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 08:39:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g65si8571053pfd.168.2015.12.12.08.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 08:39:36 -0800 (PST)
Date: Sat, 12 Dec 2015 19:39:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: flatten struct cg_proto
Message-ID: <20151212163925.GD28521@esperanza>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1449863653-6546-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Dec 11, 2015 at 02:54:12PM -0500, Johannes Weiner wrote:
> There are no more external users of struct cg_proto, flatten the
> structure into struct mem_cgroup.
> 
> Since using those struct members doesn't stand out as much anymore,
> add cgroup2 static branches to make it clearer which code is legacy.
> 
> Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me, thanks!

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
