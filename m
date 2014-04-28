Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1C36B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:00:46 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id b13so688994wgh.31
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:00:46 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTP id dt5si4134596wib.88.2014.04.28.11.00.45
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 11:00:45 -0700 (PDT)
Date: Mon, 28 Apr 2014 18:00:25 +0000
From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140428180025.GC25689@ubuntumail>
References: <20140416154650.GA3034@alpha.arachsys.com>
 <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com>
 <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com>
 <20140422200531.GA19334@alpha.arachsys.com>
 <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140423084942.560ae837@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dwight Engen <dwight.engen@oracle.com>
Cc: Marian Marinov <mm@yuhu.biz>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Daniel Walsh <dwalsh@redhat.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

Quoting Dwight Engen (dwight.engen@oracle.com):
> On Wed, 23 Apr 2014 09:07:28 +0300
> Marian Marinov <mm@yuhu.biz> wrote:
> 
> > On 04/22/2014 11:05 PM, Richard Davies wrote:
> > > Dwight Engen wrote:
> > >> Richard Davies wrote:
> > >>> Vladimir Davydov wrote:
> > >>>> In short, kmem limiting for memory cgroups is currently broken.
> > >>>> Do not use it. We are working on making it usable though.
> > > ...
> > >>> What is the best mechanism available today, until kmem limits
> > >>> mature?
> > >>>
> > >>> RLIMIT_NPROC exists but is per-user, not per-container.
> > >>>
> > >>> Perhaps there is an up-to-date task counter patchset or similar?
> > >>
> > >> I updated Frederic's task counter patches and included Max
> > >> Kellermann's fork limiter here:
> > >>
> > >> http://thread.gmane.org/gmane.linux.kernel.containers/27212
> > >>
> > >> I can send you a more recent patchset (against 3.13.10) if you
> > >> would find it useful.
> > >
> > > Yes please, I would be interested in that. Ideally even against
> > > 3.14.1 if you have that too.
> > 
> > Dwight, do you have these patches in any public repo?
> > 
> > I would like to test them also.
> 
> Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
> 
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> git://github.com/dwengen/linux.git cpuacct-task-limit-3.14

Thanks, Dwight.  FWIW I'm agreed with Tim, Dwight, Richard, and Marian
that a task limit would be a proper cgroup extension, and specifically
that approximating that with a kmem limit is not a reasonable substitute.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
