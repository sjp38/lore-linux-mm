Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4636B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:09:49 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id d17-v6so3535408ybl.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:09:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7-v6sor327608ybm.148.2018.08.07.08.09.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 08:09:47 -0700 (PDT)
Date: Tue, 7 Aug 2018 08:09:44 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180807150944.GA3978217@devbig004.ftw2.facebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806200637.GJ10003@dhcp22.suse.cz>
 <20180806201907.GH410235@devbig004.ftw2.facebook.com>
 <20180807071332.GR10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807071332.GR10003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Tue, Aug 07, 2018 at 09:13:32AM +0200, Michal Hocko wrote:
> > * It's the same information as memory.stat but would be in a different
> >   format and will likely be a bit of an eyeful.
> >
> > * It can easily become a really long line.  Each kernel log can be ~1k
> >   in length and there can be other limits in the log pipeline
> >   (e.g. netcons).
> 
> Are we getting close to those limits?

Yeah, I think the stats we have can already go close to or over 500
bytes easily, which is already pushing the netcons udp packet size
limit.

> > * The information is already multi-line and cgroup oom kills don't
> >   take down the system, so there's no need to worry about scroll back
> >   that much.  Also, not printing recursive info means the output is
> >   well-bound.
> 
> Well, on the other hand you can have a lot of memcgs under OOM and then
> swamp the log a lot.

idk, the info dump is already multi-line.  If we have a lot of memcgs
under OOM, we're already kinda messed up (e.g. we can't tell which
line is for which oom).  This adds to that to a certain extent but not
by much.  In practice, this doesn't seem to be a signficant problem.

Thanks.

-- 
tejun
