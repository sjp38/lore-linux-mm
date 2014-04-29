Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDFC6B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 03:25:22 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so5463507eek.18
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 00:25:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si25811885eel.260.2014.04.29.00.25.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 00:25:20 -0700 (PDT)
Date: Tue, 29 Apr 2014 09:25:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429072515.GB15058@dhcp22.suse.cz>
References: <20140416154650.GA3034@alpha.arachsys.com>
 <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com>
 <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com>
 <20140422200531.GA19334@alpha.arachsys.com>
 <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com>
 <20140428180025.GC25689@ubuntumail>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140428180025.GC25689@ubuntumail>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Marian Marinov <mm@yuhu.biz>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Daniel Walsh <dwalsh@redhat.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Mon 28-04-14 18:00:25, Serge Hallyn wrote:
> Quoting Dwight Engen (dwight.engen@oracle.com):
> > On Wed, 23 Apr 2014 09:07:28 +0300
> > Marian Marinov <mm@yuhu.biz> wrote:
> > 
> > > On 04/22/2014 11:05 PM, Richard Davies wrote:
> > > > Dwight Engen wrote:
> > > >> Richard Davies wrote:
> > > >>> Vladimir Davydov wrote:
> > > >>>> In short, kmem limiting for memory cgroups is currently broken.
> > > >>>> Do not use it. We are working on making it usable though.
> > > > ...
> > > >>> What is the best mechanism available today, until kmem limits
> > > >>> mature?
> > > >>>
> > > >>> RLIMIT_NPROC exists but is per-user, not per-container.
> > > >>>
> > > >>> Perhaps there is an up-to-date task counter patchset or similar?
> > > >>
> > > >> I updated Frederic's task counter patches and included Max
> > > >> Kellermann's fork limiter here:
> > > >>
> > > >> http://thread.gmane.org/gmane.linux.kernel.containers/27212
> > > >>
> > > >> I can send you a more recent patchset (against 3.13.10) if you
> > > >> would find it useful.
> > > >
> > > > Yes please, I would be interested in that. Ideally even against
> > > > 3.14.1 if you have that too.
> > > 
> > > Dwight, do you have these patches in any public repo?
> > > 
> > > I would like to test them also.
> > 
> > Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
> > 
> > git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> > git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
> 
> Thanks, Dwight.  FWIW I'm agreed with Tim, Dwight, Richard, and Marian
> that a task limit would be a proper cgroup extension, and specifically
> that approximating that with a kmem limit is not a reasonable substitute.

The current state of the kmem limit, which is improving a lot thanks to
Vladimir, is not a reason for a new extension/controller. We are just
not yet there.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
