Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 40FBB4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:47:30 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so43881wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:47:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o126si40330627wmb.73.2016.02.04.12.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:47:29 -0800 (PST)
Date: Thu, 4 Feb 2016 15:46:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm: memcontrol: report slab usage in cgroup2
 memory.stat
Message-ID: <20160204204639.GE8208@cmpxchg.org>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
 <bbc5780485f59f276ad61bcbcf5b7ddb027a0669.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbc5780485f59f276ad61bcbcf5b7ddb027a0669.1454589800.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 04:03:38PM +0300, Vladimir Davydov wrote:
> Show how much memory is used for storing reclaimable and unreclaimable
> in-kernel data structures allocated from slab caches.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
