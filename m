Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2B9A6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:45:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y10so57373475qty.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 13:45:56 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id e198si19240ybf.157.2016.09.14.13.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 13:45:55 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id v2so1927339ywg.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 13:45:55 -0700 (PDT)
Date: Wed, 14 Sep 2016 16:45:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: consolidate cgroup socket tracking
Message-ID: <20160914204553.GC6832@htj.duckdns.org>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
 <20160914194846.11153-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 14, 2016 at 03:48:46PM -0400, Johannes Weiner wrote:
> The cgroup core and the memory controller need to track socket
> ownership for different purposes, but the tracking sites being
> entirely different is kind of ugly.
> 
> Be a better citizen and rename the memory controller callbacks to
> match the cgroup core callbacks, then move them to the same place.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

For 1-3,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
