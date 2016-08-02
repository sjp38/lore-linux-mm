Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA3376B025F
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:24:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so108281225wml.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:24:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k184si4186816wmg.87.2016.08.02.10.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:24:20 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:21:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802172137.GA6637@cmpxchg.org>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 06:00:48PM +0300, Vladimir Davydov wrote:
> An offline memory cgroup might have anonymous memory or shmem left
> charged to it and no swap. Since only swap entries pin the id of an
> offline cgroup, such a cgroup will have no id and so an attempt to
> swapout its anon/shmem will not store memory cgroup info in the swap
> cgroup map. As a result, memcg->swap or memcg->memsw will never get
> uncharged from it and any of its ascendants.
> 
> Fix this by always charging swapout to the first ancestor cgroup that
> hasn't released its id yet.
> 
> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: <stable@vger.kernel.org>	[3.19+]

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
