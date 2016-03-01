Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f173.google.com (mail-yw0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id 61E5C6B0256
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 12:06:55 -0500 (EST)
Received: by mail-yw0-f173.google.com with SMTP id e63so153734927ywc.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 09:06:55 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id l203si1226884ybl.30.2016.03.01.09.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 09:06:54 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id f6so9658753ywa.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 09:06:54 -0800 (PST)
Date: Tue, 1 Mar 2016 12:06:52 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] cgroup: reset css on destruction
Message-ID: <20160301170652.GG3965@htj.duckdns.org>
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
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Applied to cgroup/for-4.6.  Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
