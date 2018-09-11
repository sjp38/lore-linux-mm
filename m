Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 717858E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 11:35:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w12-v6so31575536oie.12
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:35:06 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i16-v6si11892754oii.4.2018.09.11.08.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 08:35:05 -0700 (PDT)
Date: Tue, 11 Sep 2018 08:34:48 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911153448.GB28828@tower.DHCP.thefacebook.com>
References: <20180910215622.4428-1-guro@fb.com>
 <20180911121141.GS10951@dhcp22.suse.cz>
 <0ea4cdbd-dc3f-1b66-8a5f-8d67ab0e2bc9@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <0ea4cdbd-dc3f-1b66-8a5f-8d67ab0e2bc9@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, Sep 11, 2018 at 02:41:04PM +0200, peter enderborg wrote:
> On 09/11/2018 02:11 PM, Michal Hocko wrote:
> > Why is this a problem though? IIRC this event was deliberately placed
> > outside of the oom path because we wanted to count allocation failures
> > and this is also documented that way
> >
> >           oom
> >                 The number of time the cgroup's memory usage was
> >                 reached the limit and allocation was about to fail.
> >
> >                 Depending on context result could be invocation of OOM
> >                 killer and retrying allocation or failing a
> >
> > One could argue that we do not apply the same logic to GFP_NOWAIT
> > requests but in general I would like to see a good reason to change
> > the behavior and if it is really the right thing to do then we need to
> > update the documentation as well.
> >
> 
> Why not introduce a MEMCG_ALLOC_FAIL in to memcg_memory_event?

memory.events contains events which are useful (actionable) for userspace.
E.g. memory.high event may signal that high limit is reached and the workload
is slowing down by forcing into the direct reclaim.

Kernel allocation failure is not a userspace problem, so it's not actionable.
I'd say memory.stat can be a good place for a such counter.

Thanks!
