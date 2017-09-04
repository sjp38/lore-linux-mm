Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 773046B04C3
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 13:51:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s137so1757542pfs.4
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 10:51:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 33si5660095ply.696.2017.09.04.10.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 10:51:49 -0700 (PDT)
Date: Mon, 4 Sep 2017 18:51:18 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170904175118.GA25219@castle.DHCP.thefacebook.com>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <CALvZod4TtA8myYSqCL87dDXfyk1qkYx+v-MO6nt-cA+bKTcGUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod4TtA8myYSqCL87dDXfyk1qkYx+v-MO6nt-cA+bKTcGUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 04, 2017 at 10:32:37AM -0700, Shakeel Butt wrote:
> On Mon, Sep 4, 2017 at 7:21 AM, Roman Gushchin <guro@fb.com> wrote:
> > Introducing of cgroup-aware OOM killer changes the victim selection
> > algorithm used by default: instead of picking the largest process,
> > it will pick the largest memcg and then the largest process inside.
> >
> > This affects only cgroup v2 users.
> >
> > To provide a way to use cgroups v2 if the old OOM victim selection
> > algorithm is preferred for some reason, the nogroupoom mount option
> > is added.
> 
> Is this mount option or boot parameter? From the code, it seems like a
> boot parameter.

Sure, you're right.

Fixed version below.

Thank you!

--
