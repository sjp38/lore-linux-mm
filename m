Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5166B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 15:28:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b9so6624561wmh.5
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 12:28:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s5sor6467436wra.28.2017.10.30.12.28.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 12:28:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171030082916.x6xaqd4pgs2moy4y@dhcp22.suse.cz>
References: <20171024172330.GA3973@cmpxchg.org> <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org> <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com> <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org> <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org> <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
 <20171030082916.x6xaqd4pgs2moy4y@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 30 Oct 2017 12:28:13 -0700
Message-ID: <CALvZod65sU+wujxAR9AqTdbMHkHsMsOyfNXYf1t=w1BEpx5LHw@mail.gmail.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 30, 2017 at 1:29 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 27-10-17 13:50:47, Shakeel Butt wrote:
>> > Why is OOM-disabling a thing? Why isn't this simply a "kill everything
>> > else before you kill me"? It's crashing the kernel in trying to
>> > protect a userspace application. How is that not insane?
>>
>> In parallel to other discussion, I think we should definitely move
>> from "completely oom-disabled" semantics to something similar to "kill
>> me last" semantics. Is there any objection to this idea?
>
> Could you be more specific what you mean?
>

I get the impression that the main reason behind the complexity of
oom-killer is allowing processes to be protected from the oom-killer
i.e. disabling oom-killing a process by setting
/proc/[pid]/oom_score_adj to -1000. So, instead of oom-disabling, add
an interface which will let users/admins to set a process to be
oom-killed as a last resort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
