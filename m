Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 610736B0010
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:59:08 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k85-v6so2429783ita.0
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:59:08 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c205-v6sor630150itb.23.2018.06.29.11.59.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 11:59:07 -0700 (PDT)
Date: Fri, 29 Jun 2018 11:59:04 -0700
In-Reply-To: <20180629072132.GA13860@dhcp22.suse.cz>
Message-Id: <xr93bmbtju6f.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20180628151101.25307-1-mhocko@kernel.org> <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
 <20180629072132.GA13860@dhcp22.suse.cz>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 28-06-18 16:19:07, Greg Thelen wrote:
>> Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> > +	if (mem_cgroup_out_of_memory(memcg, mask, order))
>> > +		return OOM_SUCCESS;
>> > +
>> > +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
>> > +		"This looks like a misconfiguration or a kernel bug.");
>> 
>> I'm not sure here if the warning should here or so strongly worded.  It
>> seems like the current task could be oom reaped with MMF_OOM_SKIP and
>> thus mem_cgroup_out_of_memory() will return false.  So there's nothing
>> alarming in that case.
>
> If the task is reaped then its charges should be released as well and
> that means that we should get below the limit. Sure there is some room
> for races but this should be still unlikely. Maybe I am just
> underestimating though.
>
> What would you suggest instead?

I suggest checking MMF_OOM_SKIP or deleting the warning.  But I don't
feel strongly.
