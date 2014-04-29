Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 334B66B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:06:45 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so550195eek.29
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 10:06:44 -0700 (PDT)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id y6si27719511eep.77.2014.04.29.10.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 10:06:43 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so558509eei.0
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 10:06:43 -0700 (PDT)
Date: Tue, 29 Apr 2014 19:06:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429170639.GA25609@dhcp22.suse.cz>
References: <20140422200531.GA19334@alpha.arachsys.com>
 <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com>
 <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@google.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, containers@lists.linux-foundation.org, Daniel Walsh <dwalsh@redhat.com>, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

On Tue 29-04-14 09:59:30, Tim Hockin wrote:
> Here's the reason it doesn't work for us: It doesn't work. 

There is a "simple" solution for that. Help us to fix it.

> It was something like 2 YEARS since we first wanted this, and it STILL
> does not work.

My recollection is that it was primarily Parallels and Google asking for
the kmem accounting. The reason why I didn't fight against inclusion
although the implementation at the time didn't have a proper slab
shrinking implemented was that that would happen later. Well, that later
hasn't happened yet and we are slowly getting there.

> You're postponing a pretty simple request indefinitely in
> favor of a much more complex feature, which still doesn't really give
> me what I want. 

But we cannot simply add a new interface that will have to be maintained
for ever just because something else that is supposed to workaround bugs.

> What I want is an API that works like rlimit but per-cgroup, rather
> than per-UID.

You can use an out-of-tree patchset for the time being or help to get
kmem into shape. If there are principal reasons why kmem cannot be used
then you better articulate them.

> On Tue, Apr 29, 2014 at 9:51 AM, Frederic Weisbecker <fweisbec@gmail.com> wrote:
> > On Tue, Apr 29, 2014 at 09:06:22AM -0700, Tim Hockin wrote:
> >> Why the insistence that we manage something that REALLY IS a
> >> first-class concept (hey, it has it's own RLIMIT) as a side effect of
> >> something that doesn't quite capture what we want to achieve?
> >
> > It's not a side effect, the kmem task stack control was partly
> > motivated to solve forkbomb issues in containers.
> >
> > Also in general if we can reuse existing features and code to solve
> > a problem without disturbing side issues, we just do it.
> >
> > Now if kmem doesn't solve the issue for you for any reason, or it does
> > but it brings other problems that aren't fixable in kmem itself, we can
> > certainly reconsider this cgroup subsystem. But I haven't yet seen
> > argument of this kind yet.
> >
> >>
> >> Is there some specific technical reason why you think this is a bad
> >> idea?
> >> I would think, especially in a more unified hierarchy world,
> >> that more cgroup controllers with smaller sets of responsibility would
> >> make for more manageable code (within limits, obviously).
> >
> > Because it's core code and it adds complications and overhead in the
> > fork/exit path. We just don't add new core code just for the sake of
> > slightly prettier interfaces.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
