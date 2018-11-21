Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEAD6B254C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:56:33 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id e8-v6so1633010ljg.22
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:56:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a66-v6sor22834572ljf.31.2018.11.21.00.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 00:56:32 -0800 (PST)
Date: Wed, 21 Nov 2018 11:56:29 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: Re:Re: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181121085629.exbp7cjb56fpalxy@esperanza>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dong <bauers@126.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 21, 2018 at 04:46:48PM +0800, dong wrote:
> Sorry, I found when I ran `echo 3 >  /proc/sys/vm/drop_caches`, the
> leak memory was released very slowly. 
> 
> The `Page Cache` of the opened log file is the reason to cause leak.
> Because the `struct page` contains `struct mem_cgroup *mem_cgroup`
> which has a large chunk of memory. Thanks everyone for helping me to
> solve the problem.

Ah, so it doesn't seem to be kmem problem at all. The email I sent
several minutes ago isn't relevant then.

> The last question: If I alloc many small pages and not free them, will
> I exhaust the memory ( because every page contains `mem_cgroup` )?

Once memory usage is close to the limit, the reclaimer will kick in
automatically to free those pages and the associated dead cgroups.
