Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDDE6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:26:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f91-v6so3051506plb.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:26:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12-v6si12019188pfj.190.2018.07.24.07.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 07:25:59 -0700 (PDT)
Date: Tue, 24 Jul 2018 16:25:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724142554.GQ28386@dhcp22.suse.cz>
References: <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724135528.GK1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue 24-07-18 06:55:28, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 24, 2018 at 03:50:22PM +0200, Michal Hocko wrote:
> > > So, one good way of thinking about this, I think, could be considering
> > > it as a scoped panic_on_oom.  However panic_on_oom interacts with
> > > memcg ooms, scoping that to cgroup level should likely be how we
> > > define group oom.
> > 
> > So what are we going to do if we have a reasonable usecase when somebody
> > really wants to have group kill behavior depending on the oom domain?
> > I have hard time to imagine such a usecase but my experience tells me
> > that users will find a way I have never thought about.
> 
> So, I don't know when that happend but panic_on_oom actually has 0, 1,
> 2 settings - 0 no group oom, 1 system kill on oom of any origin, 2
> system kill only if it was a system oom.  Maybe we should just follow
> that but just start with 1?

I am sorry but I do not follow. Besides that modeling the behavior on
panic_on_oom doesn't really sound very appealing to me. The knob is a
crude hack mostly motivated by debugging (at least its non-global
variants).

So can we get back to workloads and shape the semantic on top of that
please?
-- 
Michal Hocko
SUSE Labs
