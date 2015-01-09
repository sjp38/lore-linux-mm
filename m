Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C75656B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 07:51:20 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so2098752wiw.3
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 04:51:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p10si19114797wjx.72.2015.01.09.04.51.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jan 2015 04:51:20 -0800 (PST)
Date: Fri, 9 Jan 2015 07:51:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] vmscan: force scan offline memory cgroups
Message-ID: <20150109125109.GA14475@phnom.home.cmpxchg.org>
References: <20150108170349.GA32079@phnom.home.cmpxchg.org>
 <1420790983-20270-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420790983-20270-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 09, 2015 at 11:09:43AM +0300, Vladimir Davydov wrote:
> Since commit b2052564e66d ("mm: memcontrol: continue cache reclaim from
> offlined groups") pages charged to a memory cgroup are not reparented
> when the cgroup is removed. Instead, they are supposed to be reclaimed
> in a regular way, along with pages accounted to online memory cgroups.
> 
> However, an lruvec of an offline memory cgroup will sooner or later get
> so small that it will be scanned only at low scan priorities (see
> get_scan_count()). Therefore, if there are enough reclaimable pages in
> big lruvecs, pages accounted to offline memory cgroups will never be
> scanned at all, wasting memory.
> 
> Fix this by unconditionally forcing scanning dead lruvecs from kswapd.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Looks good to me now, thank you.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
