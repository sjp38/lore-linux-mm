Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 636FD6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 09:28:54 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id k14so1667881wgh.21
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 06:28:53 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id ch1si865548wib.67.2014.04.30.06.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 06:28:52 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id hm4so963520wib.17
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 06:28:52 -0700 (PDT)
Date: Wed, 30 Apr 2014 15:28:49 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140430132846.GA17745@localhost.localdomain>
References: <20140423084942.560ae837@oracle.com>
 <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
 <20140429165114.GE6129@localhost.localdomain>
 <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com>
 <20140429214454.GF6129@localhost.localdomain>
 <5360F6B4.9010308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5360F6B4.9010308@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Walsh <dwalsh@redhat.com>
Cc: Tim Hockin <thockin@google.com>, Michal Hocko <mhocko@suse.cz>, Serge Hallyn <serge.hallyn@ubuntu.com>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, Apr 30, 2014 at 09:12:20AM -0400, Daniel J Walsh wrote:
> 
> On 04/29/2014 05:44 PM, Frederic Weisbecker wrote:
> > On Tue, Apr 29, 2014 at 09:59:30AM -0700, Tim Hockin wrote:
> >> Here's the reason it doesn't work for us: It doesn't work.  It was
> >> something like 2 YEARS since we first wanted this, and it STILL does
> >> not work.
> > When I was working on the task counter cgroup subsystem 2 years
> > ago, the patches were actually pushed back by google people, in favour
> > of task stack kmem cgroup subsystem.
> >
> > The reason was that expressing the forkbomb issue in terms of
> > number of tasks as a resource is awkward and that the real resource
> > in the game comes from kernel memory exhaustion due to task stack being
> > allocated over and over, swap ping-pong and stuffs...
> >
> > And that was a pretty good argument. I still agree with that. Especially
> > since that could solve others people issues at the same time. kmem
> > cgroup has a quite large domain of application.
> >
> >> You're postponing a pretty simple request indefinitely in
> >> favor of a much more complex feature, which still doesn't really give
> >> me what I want.  What I want is an API that works like rlimit but
> >> per-cgroup, rather than per-UID.
> > The request is simple but I don't think that adding the task counter
> > cgroup subsystem is simpler than extending the kmem code to apply limits
> > to only task stack. Especially in terms of maintainance.
> >
> > Also you guys have very good mm kernel developers who are already
> > familiar with this.
> I would look at this from a Usability point of view.  It is a lot easier
> to understand number of processes then the mount of KMEM those processes
> will need.  Setting something like
> ProcessLimit=1000 in a systemd unit file is easy to explain.

Yeah that's a fair point.

> Now if systemd has the ability to translate this into something that makes
> sense in terms of kmem cgroup, then my argument goes away.

Yeah if we keep the kmem direction, this can be a place where we do the mapping.
Now I just hope the amount of stack memory allocated doesn't differ too much per arch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
