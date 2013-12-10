Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1C96B0062
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:02:28 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so3746728qeb.13
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:02:28 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id r5si11239462qar.51.2013.12.10.00.02.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 00:02:27 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id un15so7076868pbc.41
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:02:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
Date: Tue, 10 Dec 2013 12:02:26 +0400
Message-ID: <CAA6-i6rSE+PvnvmnE_6jBZvsJ+ZJmX1pSwPBE_JZw-OTotNSxQ@mail.gmail.com>
Subject: Re: [PATCH v13 00/16] kmemcg shrinkers
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>

> Please note that in contrast to previous versions this patch-set implements
> slab shrinking only when we hit the user memory limit so that kmem allocations
> will still fail if we are below the user memory limit, but close to the kmem
> limit. This is, because the implementation of kmem-only reclaim was rather
> incomplete - we had to fail GFP_NOFS allocations since everything we could
> reclaim was only FS data. I will try to improve this and send in a separate
> patch-set, but currently it is only worthwhile setting the kmem limit to be
> greater than the user mem limit just to enable per-memcg slab accounting and
> reclaim.

That is unfortunate, but it makes sense as a first step.



-- 
E Mare, Libertas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
