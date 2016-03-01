Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CF63A6B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 14:54:46 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n186so54144507wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 11:54:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dg3si39008389wjc.17.2016.03.01.11.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 11:54:45 -0800 (PST)
Date: Tue, 1 Mar 2016 14:53:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: cleanup css_reset callback
Message-ID: <20160301195333.GA22717@cmpxchg.org>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 02:13:12PM +0300, Vladimir Davydov wrote:
>  - Do not take memcg_limit_mutex for resetting limits - the cgroup
>    cannot be altered from userspace anymore, so no need to protect them.
> 
>  - Use plain page_counter_limit() for resetting ->memory and ->memsw
>    limits instead of mem_cgrouop_resize_* helpers - we enlarge the
>    limits, so no need in special handling.
> 
>  - Reset ->swap and ->tcpmem limits as well.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
