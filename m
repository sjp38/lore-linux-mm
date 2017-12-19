Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2876B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:25:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so1554336wmc.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:25:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z64sor884186wmh.26.2017.12.19.10.25.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 10:25:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com> <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
 <20171219152444.GP3919388@devbig577.frc2.facebook.com> <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Dec 2017 10:25:12 -0800
Message-ID: <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Tue, Dec 19, 2017 at 9:33 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Tue, Dec 19, 2017 at 09:23:29AM -0800, Shakeel Butt wrote:
>> To provide consistent memory usage history using the current
>> cgroup-v2's 'swap' interface, an additional metric expressing the
>> intersection of memory and swap has to be exposed. Basically memsw is
>> the union of memory and swap. So, if that additional metric can be
>
> Exposing anonymous pages with swap backing sounds pretty trivial.
>
>> used to find the union. However for consistent memory limit
>> enforcement, I don't think there is an easy way to use current 'swap'
>> interface.
>
> Can you please go into details on why this is important?  I get that
> you can't do it as easily w/o memsw but I don't understand why this is
> a critical feature.  Why is that?
>

Making the runtime environment, an invariant is very critical to make
the management of a job easier whose instances run on different
clusters across the world. Some clusters might have different type of
swaps installed while some might not have one at all and the
availability of the swap can be dynamic (i.e. swap medium outage).

So, if users want to run multiple instances of a job across multiple
clusters, they should be able to specify the limits of their jobs
irrespective of the knowledge of cluster. The best case would be they
just submits their jobs without any config and the system figures out
the right limit and enforce that. And to figure out the right limit
and enforcing it, the consistent memory usage history and consistent
memory limit enforcement is very critical.

thanks,
Shakeel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
