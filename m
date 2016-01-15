Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1D30F828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 15:57:36 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b14so42760101wmb.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 12:57:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uw9si19973046wjc.111.2016.01.15.12.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 12:57:34 -0800 (PST)
Date: Fri, 15 Jan 2016 15:56:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Only free spare array when readers are done
Message-ID: <20160115205653.GA26524@cmpxchg.org>
References: <001a113abaa499606605294b5b17@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113abaa499606605294b5b17@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 14, 2016 at 02:33:52PM +0100, Martijn Coenen wrote:
> A spare array holding mem cgroup threshold events is kept around
> to make sure we can always safely deregister an event and have an
> array to store the new set of events in.
> 
> In the scenario where we're going from 1 to 0 registered events, the
> pointer to the primary array containing 1 event is copied to the spare
> slot, and then the spare slot is freed because no events are left.
> However, it is freed before calling synchronize_rcu(), which means
> readers may still be accessing threshold->primary after it is freed.
> 
> Fixed by only freeing after synchronize_rcu().
> 
> Signed-off-by: Martijn Coenen <maco@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
