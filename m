Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5566B0007
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 13:54:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i24-v6so5658614edq.16
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 10:54:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c16-v6si1895378edt.291.2018.08.07.10.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 10:54:12 -0700 (PDT)
Date: Tue, 7 Aug 2018 19:54:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180807175410.GI10003@dhcp22.suse.cz>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806200637.GJ10003@dhcp22.suse.cz>
 <20180806201907.GH410235@devbig004.ftw2.facebook.com>
 <20180807071332.GR10003@dhcp22.suse.cz>
 <20180807150944.GA3978217@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807150944.GA3978217@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Tue 07-08-18 08:09:44, Tejun Heo wrote:
> On Tue, Aug 07, 2018 at 09:13:32AM +0200, Michal Hocko wrote:
> > > * It's the same information as memory.stat but would be in a different
> > >   format and will likely be a bit of an eyeful.
> > >
> > > * It can easily become a really long line.  Each kernel log can be ~1k
> > >   in length and there can be other limits in the log pipeline
> > >   (e.g. netcons).
> > 
> > Are we getting close to those limits?
> 
> Yeah, I think the stats we have can already go close to or over 500
> bytes easily, which is already pushing the netcons udp packet size
> limit.
> 
> > > * The information is already multi-line and cgroup oom kills don't
> > >   take down the system, so there's no need to worry about scroll back
> > >   that much.  Also, not printing recursive info means the output is
> > >   well-bound.
> > 
> > Well, on the other hand you can have a lot of memcgs under OOM and then
> > swamp the log a lot.
> 
> idk, the info dump is already multi-line.  If we have a lot of memcgs
> under OOM, we're already kinda messed up (e.g. we can't tell which
> line is for which oom). 

Well, I am not really worried about interleaved oom reports because they
do use oom_lock so this shouldn't be a problem. I just meant to say that
a lot of memcg ooms will swamp the log and having more lines doesn't
really help.

That being said. I will not really push hard. If there is a general
consensus with this output I will not stand in the way. But I believe
that more compact oom report is both nicer and easier to read. At least
from my POV and I have processed countless number of those.
-- 
Michal Hocko
SUSE Labs
