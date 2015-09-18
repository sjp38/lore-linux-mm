Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 506106B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:30:38 -0400 (EDT)
Received: by ykft14 with SMTP id t14so46461467ykf.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 06:30:38 -0700 (PDT)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id e78si4082238ywa.21.2015.09.18.06.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 06:30:37 -0700 (PDT)
Received: by ykft14 with SMTP id t14so46460944ykf.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 06:30:36 -0700 (PDT)
Date: Fri, 18 Sep 2015 09:30:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -mm] vmscan: fix sane_reclaim helper for legacy memcg
Message-ID: <20150918133032.GA10877@mtj.duckdns.org>
References: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 18, 2015 at 03:48:00PM +0300, Vladimir Davydov wrote:
> The sane_reclaim() helper is supposed to return false for memcg reclaim
> if the legacy hierarchy is used, because the latter lacks dirty
> throttling mechanism, and so it did before it was accidentally broken by
> commit 33398cf2f360c ("memcg: export struct mem_cgroup"). Fix it.
> 
> Fixes: 33398cf2f360c ("memcg: export struct mem_cgroup")
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
