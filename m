Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8880D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 18:15:59 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so4505556wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:15:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v124si26362326wmg.0.2016.02.09.15.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 15:15:58 -0800 (PST)
Date: Tue, 9 Feb 2016 18:15:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 6/6] mm: workingset: make shadow node shrinker memcg
 aware
Message-ID: <20160209231505.GB32427@cmpxchg.org>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
 <958fc0b9f99f5cabbc3c1f6133a615239d9c05ff.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <958fc0b9f99f5cabbc3c1f6133a615239d9c05ff.1455025246.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 09, 2016 at 04:55:54PM +0300, Vladimir Davydov wrote:
> Workingset code was recently made memcg aware, but shadow node shrinker
> is still global. As a result, one small cgroup can consume all memory
> available for shadow nodes, possibly hurting other cgroups by reclaiming
> their shadow nodes, even though reclaim distances stored in its shadow
> nodes have no effect. To avoid this, we need to make shadow node
> shrinker memcg aware.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

w00t!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
