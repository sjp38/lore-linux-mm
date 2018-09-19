Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1A9A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:23:03 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id u12-v6so2496590ywu.17
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:23:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7-v6sor1601790ybp.204.2018.09.19.07.23.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 07:23:01 -0700 (PDT)
Date: Wed, 19 Sep 2018 10:22:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: remove memcg_kmem_skip_account
Message-ID: <20180919142258.GA15400@cmpxchg.org>
References: <20180919004501.178023-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919004501.178023-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 18, 2018 at 05:45:01PM -0700, Shakeel Butt wrote:
> The flag memcg_kmem_skip_account was added during the era of opt-out
> kmem accounting. There is no need for such flag in the opt-in world as
> there aren't any __GFP_ACCOUNT allocations within
> memcg_create_cache_enqueue().
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
