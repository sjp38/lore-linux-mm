Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC4296B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 09:12:48 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id ih12so1604624qab.16
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 06:12:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s6si11029379qaj.177.2014.04.30.06.12.47
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 06:12:47 -0700 (PDT)
Message-ID: <5360F6B4.9010308@redhat.com>
Date: Wed, 30 Apr 2014 09:12:20 -0400
From: Daniel J Walsh <dwalsh@redhat.com>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140422200531.GA19334@alpha.arachsys.com> <535758A0.5000500@yuhu.biz> <20140423084942.560ae837@oracle.com> <20140428180025.GC25689@ubuntumail> <20140429072515.GB15058@dhcp22.suse.cz> <20140429130353.GA27354@ubuntumail> <20140429154345.GH15058@dhcp22.suse.cz> <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com> <20140429165114.GE6129@localhost.localdomain> <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com> <20140429214454.GF6129@localhost.localdomain>
In-Reply-To: <20140429214454.GF6129@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>, Tim Hockin <thockin@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Serge Hallyn <serge.hallyn@ubuntu.com>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>


On 04/29/2014 05:44 PM, Frederic Weisbecker wrote:
> On Tue, Apr 29, 2014 at 09:59:30AM -0700, Tim Hockin wrote:
>> Here's the reason it doesn't work for us: It doesn't work.  It was
>> something like 2 YEARS since we first wanted this, and it STILL does
>> not work.
> When I was working on the task counter cgroup subsystem 2 years
> ago, the patches were actually pushed back by google people, in favour
> of task stack kmem cgroup subsystem.
>
> The reason was that expressing the forkbomb issue in terms of
> number of tasks as a resource is awkward and that the real resource
> in the game comes from kernel memory exhaustion due to task stack being
> allocated over and over, swap ping-pong and stuffs...
>
> And that was a pretty good argument. I still agree with that. Especially
> since that could solve others people issues at the same time. kmem
> cgroup has a quite large domain of application.
>
>> You're postponing a pretty simple request indefinitely in
>> favor of a much more complex feature, which still doesn't really give
>> me what I want.  What I want is an API that works like rlimit but
>> per-cgroup, rather than per-UID.
> The request is simple but I don't think that adding the task counter
> cgroup subsystem is simpler than extending the kmem code to apply limits
> to only task stack. Especially in terms of maintainance.
>
> Also you guys have very good mm kernel developers who are already
> familiar with this.
I would look at this from a Usability point of view.  It is a lot easier
to understand number of processes then the mount of KMEM those processes
will need.  Setting something like
ProcessLimit=1000 in a systemd unit file is easy to explain.  Now if
systemd has the ability to translate this into something that makes
sense in terms of kmem cgroup, then my argument goes away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
