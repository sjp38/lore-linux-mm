Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90EA06B0008
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:54:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w20-v6so2589987plp.13
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:54:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g6-v6sor2230956pll.131.2018.03.15.13.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 13:54:11 -0700 (PDT)
Date: Thu, 15 Mar 2018 13:54:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v3 0/3] mm, memcg: introduce oom policies
In-Reply-To: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Mar 2018, David Rientjes wrote:

> There are three significant concerns about the cgroup aware oom killer as
> it is implemented in -mm:
> 
>  (1) allows users to evade the oom killer by creating subcontainers or
>      using other controllers since scoring is done per cgroup and not
>      hierarchically,
> 
>  (2) unfairly compares the root mem cgroup using completely different
>      criteria than leaf mem cgroups and allows wildly inaccurate results
>      if oom_score_adj is used, and
> 
>  (3) does not allow the user to influence the decisionmaking, such that
>      important subtrees cannot be preferred or biased.
> 
> This patchset aims to fix (1) completely and, by doing so, introduces a
> completely extensible user interface that can be expanded in the future.
> 
> It preserves all functionality that currently exists in -mm and extends
> it to be generally useful outside of very specialized usecases.
> 
> It eliminates the mount option for the cgroup aware oom killer entirely
> since it is now enabled through the root mem cgroup's oom policy.

There are currently six patches in this series since additional patches on 
top of it have been proposed to fix the several issues with the current 
implementation in -mm.  The six patches address (1) and (2) above, as well 
as a couple other minor tweaks.  I believe (3) can be subsequently 
addressed after the feature has been merged since it builds upon what is 
already here and shouldn't hold it back from being merged itself.

I plan on sending out the entire series once feedback is received for the 
patches already sent.

Thanks.
