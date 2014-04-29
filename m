Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 352926B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:59:51 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id ik5so652248vcb.32
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:59:50 -0700 (PDT)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id sc7si4650464vdc.67.2014.04.29.09.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 09:59:50 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id oz11so621870veb.33
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:59:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140429165114.GE6129@localhost.localdomain>
References: <20140420142830.GC22077@alpha.arachsys.com> <20140422143943.20609800@oracle.com>
 <20140422200531.GA19334@alpha.arachsys.com> <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com> <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz> <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz> <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
From: Tim Hockin <thockin@google.com>
Date: Tue, 29 Apr 2014 09:59:30 -0700
Message-ID: <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with kmem
 limit doesn't recover after disk i/o causes limit to be hit]
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Serge Hallyn <serge.hallyn@ubuntu.com>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, containers@lists.linux-foundation.org, Daniel Walsh <dwalsh@redhat.com>, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

Here's the reason it doesn't work for us: It doesn't work.  It was
something like 2 YEARS since we first wanted this, and it STILL does
not work.  You're postponing a pretty simple request indefinitely in
favor of a much more complex feature, which still doesn't really give
me what I want.  What I want is an API that works like rlimit but
per-cgroup, rather than per-UID.

On Tue, Apr 29, 2014 at 9:51 AM, Frederic Weisbecker <fweisbec@gmail.com> wrote:
> On Tue, Apr 29, 2014 at 09:06:22AM -0700, Tim Hockin wrote:
>> Why the insistence that we manage something that REALLY IS a
>> first-class concept (hey, it has it's own RLIMIT) as a side effect of
>> something that doesn't quite capture what we want to achieve?
>
> It's not a side effect, the kmem task stack control was partly
> motivated to solve forkbomb issues in containers.
>
> Also in general if we can reuse existing features and code to solve
> a problem without disturbing side issues, we just do it.
>
> Now if kmem doesn't solve the issue for you for any reason, or it does
> but it brings other problems that aren't fixable in kmem itself, we can
> certainly reconsider this cgroup subsystem. But I haven't yet seen
> argument of this kind yet.
>
>>
>> Is there some specific technical reason why you think this is a bad
>> idea?
>> I would think, especially in a more unified hierarchy world,
>> that more cgroup controllers with smaller sets of responsibility would
>> make for more manageable code (within limits, obviously).
>
> Because it's core code and it adds complications and overhead in the
> fork/exit path. We just don't add new core code just for the sake of
> slightly prettier interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
