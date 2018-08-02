Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07B526B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 20:47:15 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w2-v6so396027wrt.13
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 17:47:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16-v6sor141154wrm.39.2018.08.01.17.47.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 17:47:13 -0700 (PDT)
MIME-Version: 1.0
References: <20180802003201.817-1-guro@fb.com> <20180802003201.817-2-guro@fb.com>
 <20180802103648.3d9f8e6d@canb.auug.org.au>
In-Reply-To: <20180802103648.3d9f8e6d@canb.auug.org.au>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 1 Aug 2018 17:47:01 -0700
Message-ID: <CALvZod6OU=qPQy6bjovTQcAu8tm=XLoSxuaVpZibJsoGUgs4qA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: introduce mem_cgroup_put() helper
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 1, 2018 at 5:37 PM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Roman,
>
> On Wed, 1 Aug 2018 17:31:59 -0700 Roman Gushchin <guro@fb.com> wrote:
> >
> > Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> > memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
> >
> > Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> > Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>
> I have no idea why my Signed-off-by is attached to this patch (or
> Andrew's for that matter) ...
>

Roman might have picked this patch from linux-next and sent as it is.

Shakeel
