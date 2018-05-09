Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD30F6B055F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:11:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b192-v6so6969848wmb.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 11:11:56 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v6-v6si6909226edd.380.2018.05.09.11.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 11:11:55 -0700 (PDT)
Date: Wed, 9 May 2018 19:07:39 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 2/2] mm: ignore memory.min of abandoned memory cgroups
Message-ID: <20180509180734.GA4856@castle.DHCP.thefacebook.com>
References: <20180503114358.7952-1-guro@fb.com>
 <20180503114358.7952-2-guro@fb.com>
 <20180503173835.GA28437@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180503173835.GA28437@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 01:38:35PM -0400, Johannes Weiner wrote:
> On Thu, May 03, 2018 at 12:43:58PM +0100, Roman Gushchin wrote:
> > If a cgroup has no associated tasks, invoking the OOM killer
> > won't help release any memory, so respecting the memory.min
> > can lead to an infinite OOM loop or system stall.
> > 
> > Let's ignore memory.min of unpopulated cgroups.
> > 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Tejun Heo <tj@kernel.org>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I wouldn't mind merging this into the previous patch. It's fairly
> small, and there is no reason to introduce an infinite OOM loop
> scenario into the tree, even if it's just for one commit.

OK, makes sense.
Here is an updated version: I've merged two commits into one,
added a small note about empty cgroups to docs and rebased to mm.

Andrew, can you, please, pull this one?
Thank you!

--
