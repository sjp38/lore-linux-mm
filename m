Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B825E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:58:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id t14-v6so792244wrr.23
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:58:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f11-v6sor419029wre.53.2018.06.19.15.58.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 15:58:50 -0700 (PDT)
MIME-Version: 1.0
References: <20180619051327.149716-1-shakeelb@google.com> <20180619161149.GA27423@cmpxchg.org>
In-Reply-To: <20180619161149.GA27423@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Jun 2018 15:58:38 -0700
Message-ID: <CALvZod56hRAjCE25Wc-+O-rc+v_t6a9n3JrD4gTRaFotkcrMCQ@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] Directed kmem charging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Jun 19, 2018 at 9:09 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Hi Shakeel,
>
> this looks generally reasonable to me.
>
> However, patch 1 introduces API that isn't used until patch 2 and 3,
> which makes reviewing harder since you have to jump back and forth
> between emails. Please fold patch 1 and introduce API along with the
> users.
>

Thanks a lot for the review. Ack, I will do as you suggested in next version.

> On Mon, Jun 18, 2018 at 10:13:24PM -0700, Shakeel Butt wrote:
> > This patchset introduces memcg variant memory allocation functions.  The
> > caller can explicitly pass the memcg to charge for kmem allocations.
> > Currently the kernel, for __GFP_ACCOUNT memory allocation requests,
> > extract the memcg of the current task to charge for the kmem allocation.
> > This patch series introduces kmem allocation functions where the caller
> > can pass the pointer to the remote memcg.  The remote memcg will be
> > charged for the allocation instead of the memcg of the caller.  However
> > the caller must have a reference to the remote memcg.  This patch series
> > also introduces scope API for targeted memcg charging. So, all the
> > __GFP_ACCOUNT alloctions within the specified scope will be charged to
> > the given target memcg.
>
> Can you open with the rationale for the series, i.e. the problem
> statement (fsnotify and bh memory footprint), *then* follow with the
> proposed solution?
>

Sure.

thanks,
Shakeel
