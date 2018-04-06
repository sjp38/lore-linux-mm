Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5D86B0006
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:36:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i12so168412wre.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:36:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 65si1136767edb.64.2018.04.06.09.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 09:36:35 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:38:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 3/4] mm: treat memory.low value inclusive
Message-ID: <20180406163802.GA16383@cmpxchg.org>
References: <20180405185921.4942-1-guro@fb.com>
 <20180405185921.4942-3-guro@fb.com>
 <20180405194526.GC27918@cmpxchg.org>
 <20180406122132.GA7185@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406122132.GA7185@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 06, 2018 at 01:21:38PM +0100, Roman Gushchin wrote:
> Updated version below.
> 
> --
> 
> From 466c35c36cae392cfee5e54a2884792972e789ee Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Thu, 5 Apr 2018 19:31:35 +0100
> Subject: [PATCH v4 3/4] mm: treat memory.low value inclusive
> 
> If memcg's usage is equal to the memory.low value, avoid reclaiming
> from this cgroup while there is a surplus of reclaimable memory.
> 
> This sounds more logical and also matches memory.high and memory.max
> behavior: both are inclusive.
> 
> Empty cgroups are not considered protected, so MEMCG_LOW events
> are not emitted for empty cgroups, if there is no more reclaimable
> memory in the system.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org

Looks good, thanks!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
