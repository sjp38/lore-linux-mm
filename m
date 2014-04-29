Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id BF8C36B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:51:20 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id t61so499905wes.11
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:51:19 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id o2si1694601wie.30.2014.04.29.09.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 09:51:19 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id z2so798334wiv.12
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:51:18 -0700 (PDT)
Date: Tue, 29 Apr 2014 18:51:16 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140429165114.GE6129@localhost.localdomain>
References: <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com>
 <20140422200531.GA19334@alpha.arachsys.com>
 <535758A0.5000500@yuhu.biz>
 <20140423084942.560ae837@oracle.com>
 <20140428180025.GC25689@ubuntumail>
 <20140429072515.GB15058@dhcp22.suse.cz>
 <20140429130353.GA27354@ubuntumail>
 <20140429154345.GH15058@dhcp22.suse.cz>
 <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Serge Hallyn <serge.hallyn@ubuntu.com>, Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, containers@lists.linux-foundation.org, Daniel Walsh <dwalsh@redhat.com>, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

On Tue, Apr 29, 2014 at 09:06:22AM -0700, Tim Hockin wrote:
> Why the insistence that we manage something that REALLY IS a
> first-class concept (hey, it has it's own RLIMIT) as a side effect of
> something that doesn't quite capture what we want to achieve?

It's not a side effect, the kmem task stack control was partly
motivated to solve forkbomb issues in containers.

Also in general if we can reuse existing features and code to solve
a problem without disturbing side issues, we just do it.

Now if kmem doesn't solve the issue for you for any reason, or it does
but it brings other problems that aren't fixable in kmem itself, we can
certainly reconsider this cgroup subsystem. But I haven't yet seen
argument of this kind yet.

> 
> Is there some specific technical reason why you think this is a bad
> idea?
> I would think, especially in a more unified hierarchy world,
> that more cgroup controllers with smaller sets of responsibility would
> make for more manageable code (within limits, obviously).

Because it's core code and it adds complications and overhead in the
fork/exit path. We just don't add new core code just for the sake of
slightly prettier interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
