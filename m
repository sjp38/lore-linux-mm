Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C49E6B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:00:45 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m63so265006qkf.14
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:00:45 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e186si249283qkf.447.2017.12.01.09.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 09:00:43 -0800 (PST)
Date: Fri, 1 Dec 2017 17:00:09 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 5/7] mm, oom: add cgroup v2 mount option for
 cgroup-aware OOM killer
Message-ID: <20171201170004.GA27436@castle.DHCP.thefacebook.com>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-6-guro@fb.com>
 <20171201084113.47lnuo3diwxts732@dhcp22.suse.cz>
 <20171201131530.GA7741@castle.DHCP.thefacebook.com>
 <20171201133145.w4b4cekruklcgtol@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171201133145.w4b4cekruklcgtol@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 01, 2017 at 02:31:45PM +0100, Michal Hocko wrote:
> On Fri 01-12-17 13:15:38, Roman Gushchin wrote:
> [...]
> > So, maybe we just need to return -EAGAIN (or may be -ENOTSUP) on any read/write
> > attempt if option is not enabled?
> 
> Yes, that would work as well. ENOTSUP sounds better to me.
> -- 
> Michal Hocko
> SUSE Labs
