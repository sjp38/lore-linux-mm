Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08E766B2A38
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:32:55 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so13579918plr.8
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:32:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k69si48435320pga.176.2018.11.21.23.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 23:32:53 -0800 (PST)
Date: Thu, 22 Nov 2018 08:32:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181122073248.GA18011@dhcp22.suse.cz>
References: <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
 <20181121162747.GR12932@dhcp22.suse.cz>
 <314D030F-2112-44E4-ABD3-A3A9B8597A3A@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <314D030F-2112-44E4-ABD3-A3A9B8597A3A@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[Please do not top post]

On Thu 22-11-18 10:19:58, 段熊春 wrote:
> I had view the slab kmem_cache_alloc function，I think the virtual netdevice object will charged to memcg.
> Becuse the function slab_pre_alloc_hook will choose a kmem_cache, which belong to current task memcg.

Only for caches which opted in for kmem accounting SLAB_ACCOUNT or for
allocations with __GFP_ACCOUNT. Is this the case for the virtual
netdevice? I would check myself but I am not familiar with data
structures in this area.

> If  virtual netdevice object not destroy by another command, the virtual netdevice object will still charged to memcg, and the memcg will still in memory.

And that is why I've noted that charging objects which are not bound to
a user context and/or generally reclaimable under memory pressure are
not good candidates for kmem accounting.
-- 
Michal Hocko
SUSE Labs
