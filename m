Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF306B03A0
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:03:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n5so6746383wrb.7
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:03:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m194si13689299wmb.55.2017.04.13.09.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 09:03:49 -0700 (PDT)
Date: Thu, 13 Apr 2017 12:03:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170413160343.GC29727@cmpxchg.org>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170330155123.GA3929@cmpxchg.org>
 <CALvZod7Dr+YaYcSpUYCMAjotnU4hH=TnZWaL6mbBzLq=O3GJTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7Dr+YaYcSpUYCMAjotnU4hH=TnZWaL6mbBzLq=O3GJTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, surenb@google.com, totte@google.com, kernel-team@android.com

On Thu, Mar 30, 2017 at 09:48:55AM -0700, Shakeel Butt wrote:
> > A more useful metric for memory pressure at this point is quantifying
> > that time you spend thrashing: time the job spends in direct reclaim
> > and on the flipside time the job waits for recently evicted pages to
> > come back. Combined, that gives you a good measure of overhead from
> > memory pressure; putting that in relation to a useful baseline of
> > meaningful work done gives you a portable scale of how effictively
> > your job is running.
> >
> > I'm working on that right now, hopefully I'll have something useful
> > soon.
> 
> Johannes, is the work you are doing only about file pages or will it
> equally apply to anon pages as well?

It will work on both, with the caveat that *any* swapin is counted as
memory delay, whereas only cache misses of recently evicted entries
count toward it (we don't have timestamped shadow entries for anon).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
