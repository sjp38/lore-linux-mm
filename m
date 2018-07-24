Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8976B0266
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:35:07 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id y10-v6so2112894ybj.20
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:35:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a14-v6sor2437444ybn.98.2018.07.24.07.35.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 07:35:06 -0700 (PDT)
Date: Tue, 24 Jul 2018 07:35:04 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724143504.GM1934745@devbig577.frc2.facebook.com>
References: <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724142820.GL1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

Lemme elaborate just a bit more.

On Tue, Jul 24, 2018 at 07:28:20AM -0700, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 24, 2018 at 04:25:54PM +0200, Michal Hocko wrote:
> > I am sorry but I do not follow. Besides that modeling the behavior on
> > panic_on_oom doesn't really sound very appealing to me. The knob is a
> > crude hack mostly motivated by debugging (at least its non-global
> > variants).
> 
> Hmm... we actually do use that quite a bit in production (moving away
> from it gradually).

So, the reason panic_on_oom is used is very similar for the reason one
would want group oom kill - workload integrity after an oom kill.
panic_on_oom is an expensive way of avoiding partial kills and the
resulting possibly inconsistent state.  Group oom can scope that down
so that we can maintain integrity per-application or domain rather
than at system level making it way cheaper.

> > So can we get back to workloads and shape the semantic on top of that
> > please?
> 
> I didn't realize we were that off track.  Don't both map to what we
> were discussing almost perfectly?

I guess the reason why panic_on_oom developed the two behaviors is
likely that the initial behavior - panicking on any oom - was too
inflexible.  We're scoping it down, so whatever problems we used to
have with panic_on_oom is less pronounced with group oom.  So, I don't
think this matters all that much in terms of practical usefulness.
Both always kliling and factoring in oom origin seem fine to me.
Let's just pick one.

Thanks.

-- 
tejun
