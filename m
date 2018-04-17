Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDF736B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:01:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z7so6536234wrg.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:01:32 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w55si1415543edd.51.2018.04.17.12.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 12:01:30 -0700 (PDT)
Date: Tue, 17 Apr 2018 20:00:56 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 3/4] mm: treat memory.low value inclusive
Message-ID: <20180417190049.GA3752@castle.DHCP.thefacebook.com>
References: <20180405185921.4942-1-guro@fb.com>
 <20180405185921.4942-3-guro@fb.com>
 <20180405194526.GC27918@cmpxchg.org>
 <20180406122132.GA7185@castle>
 <20180406163802.GA16383@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180406163802.GA16383@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Andrew!

Can you, please, pull this patchset?

Thanks!

Roman

On Fri, Apr 06, 2018 at 12:38:02PM -0400, Johannes Weiner wrote:
> On Fri, Apr 06, 2018 at 01:21:38PM +0100, Roman Gushchin wrote:
> >
> > From 466c35c36cae392cfee5e54a2884792972e789ee Mon Sep 17 00:00:00 2001
> > From: Roman Gushchin <guro@fb.com>
> > Date: Thu, 5 Apr 2018 19:31:35 +0100
> > Subject: [PATCH v4 3/4] mm: treat memory.low value inclusive
> > 
> > If memcg's usage is equal to the memory.low value, avoid reclaiming
> > from this cgroup while there is a surplus of reclaimable memory.
> > 
> > This sounds more logical and also matches memory.high and memory.max
> > behavior: both are inclusive.
> > 
> > Empty cgroups are not considered protected, so MEMCG_LOW events
> > are not emitted for empty cgroups, if there is no more reclaimable
> > memory in the system.
> > 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: kernel-team@fb.com
> > Cc: linux-mm@kvack.org
> > Cc: cgroups@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> 
> Looks good, thanks!
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
