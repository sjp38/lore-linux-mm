Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E72C06B025F
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:02:38 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so6178096wre.9
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:02:38 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w15si4290240edw.148.2017.12.01.09.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 09:02:36 -0800 (PST)
Date: Fri, 1 Dec 2017 17:01:49 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 6/7] mm, oom, docs: describe the cgroup-aware OOM
 killer
Message-ID: <20171201170149.GB27436@castle.DHCP.thefacebook.com>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-7-guro@fb.com>
 <20171201084154.l7i3fxtxd4fzrq7s@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171201084154.l7i3fxtxd4fzrq7s@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 01, 2017 at 09:41:54AM +0100, Michal Hocko wrote:
> On Thu 30-11-17 15:28:23, Roman Gushchin wrote:
> > @@ -1229,6 +1252,41 @@ to be accessed repeatedly by other cgroups, it may make sense to use
> >  POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
> >  belonging to the affected files to ensure correct memory ownership.
> >  
> > +OOM Killer
> > +~~~~~~~~~~
> > +
> > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > +It means that it treats cgroups as first class OOM entities.
> 
> This should mention groupoom mount option to enable this functionality.
> 
> Other than that looks ok to me
> Acked-by: Michal Hocko <mhocko@suse.com>
> -- 
> Michal Hocko
> SUSE Labs
