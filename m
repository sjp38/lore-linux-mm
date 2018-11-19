Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44D786B1A47
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:24:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x1-v6so14989337edh.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:24:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hb8-v6si4663442ejb.196.2018.11.19.02.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:24:29 -0800 (PST)
Date: Mon, 19 Nov 2018 11:24:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181119102428.GE22247@dhcp22.suse.cz>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181119083045.m5rhvbsze4h5l6jq@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: dong <bauers@126.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guroan@gmail.com>

[Cc Roman - the email thread starts
http://lkml.kernel.org/r/20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org]

On Mon 19-11-18 11:30:45, Vladimir Davydov wrote:
> On Sun, Nov 18, 2018 at 08:44:14AM +0800, dong wrote:
> > First of all,I can see memory leak when I run a??free -ga?? command.
> 
> This doesn't mean there's a leak. The kernel may postpone freeing memory
> until there's memory pressure. In particular cgroup objects are not
> released until there are objects allocated from the corresponding kmem
> caches. Those objects may be inodes or dentries, which are freed lazily.
> Looks like restarting a service causes recreation of a memory cgroup and
> hence piling up dead cgroups. Try to drop caches.

This seems similar to what Roman was looking recently. All the fixes
should be merged in the current Linus tree IIRC.
-- 
Michal Hocko
SUSE Labs
