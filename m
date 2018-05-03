Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 663F76B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 13:36:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d4-v6so12683560wrn.15
        for <linux-mm@kvack.org>; Thu, 03 May 2018 10:36:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e6-v6si3608263edk.274.2018.05.03.10.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 May 2018 10:36:49 -0700 (PDT)
Date: Thu, 3 May 2018 13:38:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 2/2] mm: ignore memory.min of abandoned memory cgroups
Message-ID: <20180503173835.GA28437@cmpxchg.org>
References: <20180503114358.7952-1-guro@fb.com>
 <20180503114358.7952-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503114358.7952-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 12:43:58PM +0100, Roman Gushchin wrote:
> If a cgroup has no associated tasks, invoking the OOM killer
> won't help release any memory, so respecting the memory.min
> can lead to an infinite OOM loop or system stall.
> 
> Let's ignore memory.min of unpopulated cgroups.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I wouldn't mind merging this into the previous patch. It's fairly
small, and there is no reason to introduce an infinite OOM loop
scenario into the tree, even if it's just for one commit.
