Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3B76B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:16:15 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id j7so6462229pgv.20
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:16:15 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y7si5004534plh.9.2017.12.01.05.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 05:16:14 -0800 (PST)
Date: Fri, 1 Dec 2017 13:15:38 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 5/7] mm, oom: add cgroup v2 mount option for
 cgroup-aware OOM killer
Message-ID: <20171201131530.GA7741@castle.DHCP.thefacebook.com>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-6-guro@fb.com>
 <20171201084113.47lnuo3diwxts732@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171201084113.47lnuo3diwxts732@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 01, 2017 at 09:41:13AM +0100, Michal Hocko wrote:
> On Thu 30-11-17 15:28:22, Roman Gushchin wrote:
> > Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> > OOM killer. If not set, the OOM selection is performed in
> > a "traditional" per-process way.
> > 
> > The behavior can be changed dynamically by remounting the cgroupfs.
> 
> Is it ok to create oom_group if the option is not enabled? This looks
> confusing. I forgot all the details about how cgroup core creates file
> so I do not have a good idea how to fix this.

I don't think we do show/hide interface files dynamically.
Even for things like socket memory which can be disabled by the boot option,
we don't hide the corresponding stats entry.

So, maybe we just need to return -EAGAIN (or may be -ENOTSUP) on any read/write
attempt if option is not enabled?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
