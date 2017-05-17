Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 850356B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:51:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t126so12611684pgc.9
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:51:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n21si2444860pfi.7.2017.05.17.08.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:51:37 -0700 (PDT)
Date: Wed, 17 May 2017 16:50:42 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
Message-ID: <20170517155042.GA4133@castle>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
 <1494555922.21563.1.camel@gmail.com>
 <20170512164206.GA22367@cmpxchg.org>
 <CAKTCnz=vj9-C2-XPcijB=fZOVVdxvqZvLEA93xXtRZmF+y3-Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKTCnz=vj9-C2-XPcijB=fZOVVdxvqZvLEA93xXtRZmF+y3-Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, May 17, 2017 at 08:03:03AM +1000, Balbir Singh wrote:
> On Sat, May 13, 2017 at 2:42 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Fri, May 12, 2017 at 12:25:22PM +1000, Balbir Singh wrote:
> >>
> >> It sounds like memcg accumlates both global and memcg reclaim driver
> >> counts -- is this what we want?
> >
> > Yes.
> >
> > Consider a fully containerized system that is using only memory.low
> > and thus exclusively global reclaim to enforce the partitioning, NOT
> > artificial limits and limit reclaim. In this case, we still want to
> > know how much reclaim activity each group is experiencing.
> 
> But its also confusing to see memcg.stat's value being greater
> than the global value? At-least for me. For example PGSTEAL_DIRECT
> inside a memcg > global value of PGSTEAL_DIRECT. Do we make
> memcg.stat values sum of all impact on memcg or local to memcg?

Yes, I think that global counters should include both results of
global and per-cgroup reclaim. I will prepare a separate patch for this.

Thank you!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
