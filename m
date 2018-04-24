Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7DAF6B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:00:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c73so2809302qke.2
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:00:43 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o186si15466655qkb.68.2018.04.24.07.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 07:00:41 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:54:15 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180424135409.GA28080@castle.DHCP.thefacebook.com>
References: <20180423123610.27988-1-guro@fb.com>
 <20180424123002.utwbm54mu46q6aqs@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180424123002.utwbm54mu46q6aqs@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>

Hi Vladimir!

> On Mon, Apr 23, 2018 at 01:36:10PM +0100, Roman Gushchin wrote:
> > +  memory.min
> > +	A read-write single value file which exists on non-root
> > +	cgroups.  The default is "0".
> > +
> > +	Hard memory protection.  If the memory usage of a cgroup
> > +	is within its effective min boundary, the cgroup's memory
> > +	won't be reclaimed under any conditions. If there is no
> > +	unprotected reclaimable memory available, OOM killer
> > +	is invoked.
> 
> What will happen if all tasks attached to a cgroup are killed by OOM,
> but its memory usage is still within memory.min? Will memory.min be
> ignored then?

Not really.

I don't think it's a big problem as long as a user isn't doing
something weird (e.g. moving processes with significant
amount of charged memory to other cgroups).

But what we can do here, is to ignore memory.min of empty cgroups
(patch below), it will resolve some edge cases like this.

Thanks!

--------------------------------------------------------------------------------
