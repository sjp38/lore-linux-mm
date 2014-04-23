Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DE3196B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 08:50:21 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so746914pde.39
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 05:50:21 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id dg5si579948pbc.265.2014.04.23.05.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 05:50:18 -0700 (PDT)
Date: Wed, 23 Apr 2014 08:49:42 -0400
From: Dwight Engen <dwight.engen@oracle.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140423084942.560ae837@oracle.com>
In-Reply-To: <535758A0.5000500@yuhu.biz>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
	<20140422143943.20609800@oracle.com>
	<20140422200531.GA19334@alpha.arachsys.com>
	<535758A0.5000500@yuhu.biz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marian Marinov <mm@yuhu.biz>
Cc: Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, 23 Apr 2014 09:07:28 +0300
Marian Marinov <mm@yuhu.biz> wrote:

> On 04/22/2014 11:05 PM, Richard Davies wrote:
> > Dwight Engen wrote:
> >> Richard Davies wrote:
> >>> Vladimir Davydov wrote:
> >>>> In short, kmem limiting for memory cgroups is currently broken.
> >>>> Do not use it. We are working on making it usable though.
> > ...
> >>> What is the best mechanism available today, until kmem limits
> >>> mature?
> >>>
> >>> RLIMIT_NPROC exists but is per-user, not per-container.
> >>>
> >>> Perhaps there is an up-to-date task counter patchset or similar?
> >>
> >> I updated Frederic's task counter patches and included Max
> >> Kellermann's fork limiter here:
> >>
> >> http://thread.gmane.org/gmane.linux.kernel.containers/27212
> >>
> >> I can send you a more recent patchset (against 3.13.10) if you
> >> would find it useful.
> >
> > Yes please, I would be interested in that. Ideally even against
> > 3.14.1 if you have that too.
> 
> Dwight, do you have these patches in any public repo?
> 
> I would like to test them also.

Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:

git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
 
> Marian
> 
> >
> > Thanks,
> >
> > Richard.
> > --
> > To unsubscribe from this list: send the line "unsubscribe cgroups"
> > in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
