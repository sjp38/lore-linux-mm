Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 615DD6B255E
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:10:45 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so7067969plk.12
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:10:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b14si24064539pfc.156.2018.11.21.01.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 01:10:44 -0800 (PST)
Date: Wed, 21 Nov 2018 10:10:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re:Re: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181121091041.GM12932@dhcp22.suse.cz>
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
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 21-11-18 16:46:48, dong wrote:
> The last question: If I alloc many small pages and not free them, will
> I exhaust the memory ( because every page contains `mem_cgroup` )?

No, the memory will get reclaimed on the memory pressure or for
anonymous one (malloc) when the process allocating it terminates,
-- 
Michal Hocko
SUSE Labs
