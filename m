Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 17F966B0256
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 14:55:45 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p65so49027336wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 11:55:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 62si844544wmc.4.2016.03.01.11.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 11:55:44 -0800 (PST)
Date: Tue, 1 Mar 2016 14:54:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] cgroup: reset css on destruction
Message-ID: <20160301195438.GB22717@cmpxchg.org>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
 <92b11b89791412df49e73597b87912e8f143a3f7.1456830735.git.vdavydov@virtuozzo.com>
 <20160301163018.GE3965@htj.duckdns.org>
 <20160301165630.GB2426@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301165630.GB2426@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 07:56:30PM +0300, Vladimir Davydov wrote:
> From: Vladimir Davydov <vdavydov@virtuozzo.com>
> Subject: [PATCH] cgroup: reset css on destruction
> 
> An associated css can be around for quite a while after a cgroup
> directory has been removed. In general, it makes sense to reset it to
> defaults so as not to worry about any remnants. For instance, memory
> cgroup needs to reset memory.low, otherwise pages charged to a dead
> cgroup might never get reclaimed. There's ->css_reset callback, which
> would fit perfectly for the purpose. Currently, it's only called when a
> subsystem is disabled in the unified hierarchy and there are other
> subsystems dependant on it. Let's call it on css destruction as well.
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

It's already in a git tree, but FWIW

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
