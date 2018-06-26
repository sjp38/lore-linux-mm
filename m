Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C59C66B0008
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 14:01:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q12-v6so1217537wmf.9
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 11:01:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor1086953wrp.72.2018.06.26.11.01.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Jun 2018 11:01:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180625230659.139822-1-shakeelb@google.com> <20180625230659.139822-2-shakeelb@google.com>
 <CAOQ4uxiV75+X3dMLS93iXqwmSU6eKPOUocdkXiR7MQZhEjotQg@mail.gmail.com>
In-Reply-To: <CAOQ4uxiV75+X3dMLS93iXqwmSU6eKPOUocdkXiR7MQZhEjotQg@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 26 Jun 2018 11:00:53 -0700
Message-ID: <CALvZod5ARMZL+eD8-mrxeBvxJcuVPXaCwWEgUyQw85xXWxHauA@mail.gmail.com>
Subject: Re: [PATCH 1/2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>

On Mon, Jun 25, 2018 at 10:49 PM Amir Goldstein <amir73il@gmail.com> wrote:
>
...
>
> The verb 'unuse' takes an argument memcg and 'uses' it - too weird.
> You can use 'override'/'revert' verbs like override_creds or just call
> memalloc_use_memcg(old_memcg) since there is no reference taken
> anyway in use_memcg and no reference released in unuse_memcg.
>
> Otherwise looks good to me.
>

Thanks for your feedback. Just using memalloc_use_memcg(old_memcg) and
ignoring the return seems more simple. I will wait for feedback from
other before changing anything.

thanks,
Shakeel
