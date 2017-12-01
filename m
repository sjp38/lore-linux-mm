Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 631136B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:41:57 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g13so4152033pln.20
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:41:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k17si4883867pfa.130.2017.12.01.00.41.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 00:41:56 -0800 (PST)
Date: Fri, 1 Dec 2017 09:41:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 6/7] mm, oom, docs: describe the cgroup-aware OOM
 killer
Message-ID: <20171201084154.l7i3fxtxd4fzrq7s@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-7-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130152824.1591-7-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 30-11-17 15:28:23, Roman Gushchin wrote:
> @@ -1229,6 +1252,41 @@ to be accessed repeatedly by other cgroups, it may make sense to use
>  POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
>  belonging to the affected files to ensure correct memory ownership.
>  
> +OOM Killer
> +~~~~~~~~~~
> +
> +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> +It means that it treats cgroups as first class OOM entities.

This should mention groupoom mount option to enable this functionality.

Other than that looks ok to me
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
