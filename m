Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5F486B0261
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:13:56 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c3so6220414wrd.0
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:13:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si2610287edf.166.2017.12.01.09.13.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 09:13:55 -0800 (PST)
Date: Fri, 1 Dec 2017 18:13:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 6/7] mm, oom, docs: describe the cgroup-aware OOM
 killer
Message-ID: <20171201171353.jkv2nq2m3y3hiejn@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-7-guro@fb.com>
 <20171201084154.l7i3fxtxd4fzrq7s@dhcp22.suse.cz>
 <20171201170149.GB27436@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201170149.GB27436@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 01-12-17 17:01:49, Roman Gushchin wrote:
[...]
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index c80a147f94b7..ff8e92db636d 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1049,6 +1049,9 @@ PAGE_SIZE multiple when read back.
>  	and will never kill the unkillable task, even if memory.oom_group
>  	is set.
>  
> +	If cgroup-aware OOM killer is not enabled, ENOTSUPP error
> +	is returned on attempt to access the file.
> +
>    memory.events
>  	A read-only flat-keyed file which exists on non-root cgroups.
>  	The following entries are defined.  Unless specified
> @@ -1258,6 +1261,12 @@ OOM Killer
>  Cgroup v2 memory controller implements a cgroup-aware OOM killer.
>  It means that it treats cgroups as first class OOM entities.
>  
> +Cgroup-aware OOM logic is turned off by default and requires
> +passing the "groupoom" option on mounting cgroupfs. It can also
> +by remounting cgroupfs with the following command::
> +
> +  # mount -o remount,groupoom $MOUNT_POINT
> +
>  Under OOM conditions the memory controller tries to make the best
>  choice of a victim, looking for a memory cgroup with the largest
>  memory footprint, considering leaf cgroups and cgroups with the

Looks good to me

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
