Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 984F86B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:39:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u188so1547280pfb.6
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:39:22 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x185si1790078pgb.649.2018.03.14.05.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 05:39:21 -0700 (PDT)
Date: Wed, 14 Mar 2018 12:38:52 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm v3 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
Message-ID: <20180314123851.GB20850@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803121757080.192200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803121757080.192200@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 12, 2018 at 05:57:53PM -0700, David Rientjes wrote:
> The cgroup aware oom killer is needlessly enforced for the entire system
> by a mount option.  It's unnecessary to force the system into a single
> oom policy: either cgroup aware, or the traditional process aware.

Can you, please, provide a real-life example, when using per-process
and cgroup-aware OOM killer depending on OOM scope is beneficial?

It might be quite confusing, depending on configuration.
>From inside a container you can have different types of OOMs,
depending on parent's cgroup configuration, which is not even
accessible for reading from inside.

Also, it's probably good to have an interface to show which policies
are available.

Thanks!
