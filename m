Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id F03EF6B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:55:31 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id t10-v6so2180571ywc.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:55:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h129-v6sor2704790yba.91.2018.07.24.06.55.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 06:55:31 -0700 (PDT)
Date: Tue, 24 Jul 2018 06:55:28 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724135528.GK1934745@devbig577.frc2.facebook.com>
References: <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724135022.GO28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Tue, Jul 24, 2018 at 03:50:22PM +0200, Michal Hocko wrote:
> > So, one good way of thinking about this, I think, could be considering
> > it as a scoped panic_on_oom.  However panic_on_oom interacts with
> > memcg ooms, scoping that to cgroup level should likely be how we
> > define group oom.
> 
> So what are we going to do if we have a reasonable usecase when somebody
> really wants to have group kill behavior depending on the oom domain?
> I have hard time to imagine such a usecase but my experience tells me
> that users will find a way I have never thought about.

So, I don't know when that happend but panic_on_oom actually has 0, 1,
2 settings - 0 no group oom, 1 system kill on oom of any origin, 2
system kill only if it was a system oom.  Maybe we should just follow
that but just start with 1?

Thanks.

-- 
tejun
