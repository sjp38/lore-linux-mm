Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AD7E86B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 13:57:16 -0500 (EST)
Received: by wmec201 with SMTP id c201so131073864wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 10:57:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e8si49942774wma.7.2015.11.19.10.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 10:57:15 -0800 (PST)
Date: Thu, 19 Nov 2015 13:56:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/6] Revert "kernfs: do not account ino_ida
 allocations to memcg"
Message-ID: <20151119185656.GA3941@cmpxchg.org>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <c468a2d2b39d755de2383c6ae49be6a53360a22b.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c468a2d2b39d755de2383c6ae49be6a53360a22b.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 10, 2015 at 09:34:02PM +0300, Vladimir Davydov wrote:
> This reverts commit 499611ed451508a42d1d7d1faff10177827755d5.
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
