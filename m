Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E40D16B0255
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:27:36 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so28201499wml.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:27:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h10si27516197wja.66.2015.12.11.11.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:27:36 -0800 (PST)
Date: Fri, 11 Dec 2015 14:27:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/7] mm: vmscan: do not scan anon pages if memcg swap
 limit is hit
Message-ID: <20151211192724.GD3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <04c56c92f57c90a1f626546fcfade747fbfa9ec5.1449742561.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04c56c92f57c90a1f626546fcfade747fbfa9ec5.1449742561.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:18PM +0300, Vladimir Davydov wrote:
> We don't scan anonymous memory if we ran out of swap, neither should we
> do it in case memcg swap limit is hit, because swap out is impossible
> anyway.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
