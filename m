Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8E85D6B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 13:59:41 -0500 (EST)
Received: by wmec201 with SMTP id c201so131157108wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 10:59:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h66si13925031wmf.55.2015.11.19.10.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 10:59:40 -0800 (PST)
Date: Thu, 19 Nov 2015 13:59:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/6] Revert "gfp: add __GFP_NOACCOUNT"
Message-ID: <20151119185932.GB3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <7edf2c7333f027ad6a890884558fde60b5144140.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7edf2c7333f027ad6a890884558fde60b5144140.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:03PM +0300, Vladimir Davydov wrote:
> This reverts commit 8f4fc071b1926d0b20336e2b3f8ab85c94c734c5.
> 
> Black-list kmem accounting policy (aka __GFP_NOACCOUNT) turned out to be
> fragile and difficult to maintain, because there seem to be many more
> allocations that should not be accounted than those that should be.
> Besides, false accounting an allocation might result in much worse
> consequences than not accounting at all, namely increased memory
> consumption due to pinned dead kmem caches.
> 
> So it was decided to switch to the white-list policy. This patch reverts
> bits introducing the black-list policy. The white-list policy will be
> introduced later in the series.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
