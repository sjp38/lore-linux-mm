Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA286B0006
	for <linux-mm@kvack.org>; Sun, 29 Jul 2018 15:26:27 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id u22-v6so1688026lji.9
        for <linux-mm@kvack.org>; Sun, 29 Jul 2018 12:26:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12-v6sor1986061ljj.100.2018.07.29.12.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 29 Jul 2018 12:26:25 -0700 (PDT)
Date: Sun, 29 Jul 2018 22:26:21 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180729192621.py4znecoinw5mqcp@esperanza>
References: <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
 <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
 <20180413125101.GO17484@dhcp22.suse.cz>
 <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
 <20180727193134.GA10996@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727193134.GA10996@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2018 at 03:31:34PM -0400, Johannes Weiner wrote:
> That said, the lifetime of the root reference on the ID is the online
> state, we put that in css_offline. Is there a reason we need to have
> the ID ready and the memcg in the IDR before onlining it?

I fail to see any reason for this in the code.

> Can we do something like this and not mess with the alloc/free
> sequence at all?

I guess so, and this definitely looks better to me.
