Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94CBF6B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:48:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w21-v6so1274854wmc.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:48:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e85-v6sor731771wme.39.2018.07.18.10.48.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 10:48:51 -0700 (PDT)
MIME-Version: 1.0
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com> <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
In-Reply-To: <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 18 Jul 2018 10:48:38 -0700
Message-ID: <CALvZod5UsYzNs_FJqy2U4HiZ+SdKzKZtzdK1OYcV7v_91kqn8A@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bmerry@ska.ac.za
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Jul 18, 2018 at 10:40 AM Bruce Merry <bmerry@ska.ac.za> wrote:
>
> On 18 July 2018 at 17:49, Shakeel Butt <shakeelb@google.com> wrote:
> > On Wed, Jul 18, 2018 at 8:37 AM Bruce Merry <bmerry@ska.ac.za> wrote:
> >> That sounds promising. Is there any way to tell how many zombies there
> >> are, and is there any way to deliberately create zombies? If I can
> >> produce zombies that might give me a reliable way to reproduce the
> >> problem, which could then sensibly be tested against newer kernel
> >> versions.
> >>
> >
> > Yes, very easy to produce zombies, though I don't think kernel
> > provides any way to tell how many zombies exist on the system.
> >
> > To create a zombie, first create a memcg node, enter that memcg,
> > create a tmpfs file of few KiBs, exit the memcg and rmdir the memcg.
> > That memcg will be a zombie until you delete that tmpfs file.
>
> Thanks, that makes sense. I'll see if I can reproduce the issue. Do
> you expect the same thing to happen with normal (non-tmpfs) files that
> are sitting in the page cache, and/or dentries?
>

Normal files and their dentries can get reclaimed while tmpfs will
stick and even if the data of tmpfs goes to swap, the kmem related to
tmpfs files will remain in memory.

Shakeel
