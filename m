Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB2596B026F
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:31:13 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id e6-v6so2001437ybk.23
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:31:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 74-v6sor2562143ywd.451.2018.07.24.06.31.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 06:31:13 -0700 (PDT)
Date: Tue, 24 Jul 2018 06:31:10 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
References: <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724132640.GL28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Tue, Jul 24, 2018 at 03:26:40PM +0200, Michal Hocko wrote:
> > 1. No matter what B, C or D sets, as long as A sets group oom, any oom
> >    kill inside A's subtree kills the entire subtree.
> > 
> > 2. A's group oom policy applies iff the source of the OOM is either at
> >    or above A - ie. iff the OOM is system-wide or caused by memory.max
> >    of A.
> > 
> > In #1, it doesn't matter what B, C or D sets, so it's kinda moot to
> > discuss whether they inherit A's setting or not.  A's is, if set,
> > always overriding.  In #2, what B, C or D sets matters if they also
> > set their own memory.max, so there's no reason for them to inherit
> > anything.
> > 
> > I'm actually okay with either option.  #2 is more flexible than #1 but
> > given that this is a cgroup owned property which is likely to be set
> > on per-application basis, #1 is likely good enough.
> > 
> > IIRC, we did #2 in the original implementation and the simplified one
> > is doing #1, right?
> 
> No, we've been discussing #2 unless I have misunderstood something.
> I find it rather non-intuitive that a property outside of the oom domain
> controls the behavior inside the domain. I will keep thinking about that
> though.

So, one good way of thinking about this, I think, could be considering
it as a scoped panic_on_oom.  However panic_on_oom interacts with
memcg ooms, scoping that to cgroup level should likely be how we
define group oom.

Thanks.

-- 
tejun
