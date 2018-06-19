Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 99F466B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 12:09:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g73-v6so457828wmc.5
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:09:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t46-v6si192558edb.396.2018.06.19.09.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 09:09:33 -0700 (PDT)
Date: Tue, 19 Jun 2018 12:11:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/3] Directed kmem charging
Message-ID: <20180619161149.GA27423@cmpxchg.org>
References: <20180619051327.149716-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619051327.149716-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi Shakeel,

this looks generally reasonable to me.

However, patch 1 introduces API that isn't used until patch 2 and 3,
which makes reviewing harder since you have to jump back and forth
between emails. Please fold patch 1 and introduce API along with the
users.

On Mon, Jun 18, 2018 at 10:13:24PM -0700, Shakeel Butt wrote:
> This patchset introduces memcg variant memory allocation functions.  The
> caller can explicitly pass the memcg to charge for kmem allocations.
> Currently the kernel, for __GFP_ACCOUNT memory allocation requests,
> extract the memcg of the current task to charge for the kmem allocation.
> This patch series introduces kmem allocation functions where the caller
> can pass the pointer to the remote memcg.  The remote memcg will be
> charged for the allocation instead of the memcg of the caller.  However
> the caller must have a reference to the remote memcg.  This patch series
> also introduces scope API for targeted memcg charging. So, all the
> __GFP_ACCOUNT alloctions within the specified scope will be charged to
> the given target memcg.

Can you open with the rationale for the series, i.e. the problem
statement (fsnotify and bh memory footprint), *then* follow with the
proposed solution?

Thanks!
