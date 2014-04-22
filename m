Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 285D76B006E
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:06:13 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so141326wiv.7
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:06:12 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id u9si14429453wjw.151.2014.04.22.13.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:06:11 -0700 (PDT)
Date: Tue, 22 Apr 2014 21:05:31 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140422200531.GA19334@alpha.arachsys.com>
References: <20140416154650.GA3034@alpha.arachsys.com>
 <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com>
 <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140422143943.20609800@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dwight Engen <dwight.engen@oracle.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

Dwight Engen wrote:
> Richard Davies wrote:
> > Vladimir Davydov wrote:
> > > In short, kmem limiting for memory cgroups is currently broken. Do
> > > not use it. We are working on making it usable though.
...
> > What is the best mechanism available today, until kmem limits mature?
> >
> > RLIMIT_NPROC exists but is per-user, not per-container.
> >
> > Perhaps there is an up-to-date task counter patchset or similar?
>
> I updated Frederic's task counter patches and included Max Kellermann's
> fork limiter here:
>
> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>
> I can send you a more recent patchset (against 3.13.10) if you would
> find it useful.

Yes please, I would be interested in that. Ideally even against 3.14.1 if
you have that too.

Thanks,

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
