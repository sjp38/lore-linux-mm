Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 346526B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 03:21:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id j22-v6so4552714pll.7
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 00:21:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j66-v6si8785379pfc.243.2018.06.29.00.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 00:21:35 -0700 (PDT)
Date: Fri, 29 Jun 2018 09:21:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
Message-ID: <20180629072132.GA13860@dhcp22.suse.cz>
References: <20180628151101.25307-1-mhocko@kernel.org>
 <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 28-06-18 16:19:07, Greg Thelen wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > +	if (mem_cgroup_out_of_memory(memcg, mask, order))
> > +		return OOM_SUCCESS;
> > +
> > +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> > +		"This looks like a misconfiguration or a kernel bug.");
> 
> I'm not sure here if the warning should here or so strongly worded.  It
> seems like the current task could be oom reaped with MMF_OOM_SKIP and
> thus mem_cgroup_out_of_memory() will return false.  So there's nothing
> alarming in that case.

If the task is reaped then its charges should be released as well and
that means that we should get below the limit. Sure there is some room
for races but this should be still unlikely. Maybe I am just
underestimating though.

What would you suggest instead?
-- 
Michal Hocko
SUSE Labs
