Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 06E006B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 01:02:58 -0400 (EDT)
Received: by pdea3 with SMTP id a3so17186907pde.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 22:02:57 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id kd6si37748425pad.164.2015.04.28.22.02.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 22:02:57 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so17283351pdb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 22:02:57 -0700 (PDT)
Date: Wed, 29 Apr 2015 14:02:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 0/3] idle memory tracking
Message-ID: <20150429050247.GB27051@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1430217477.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Apr 28, 2015 at 03:24:39PM +0300, Vladimir Davydov wrote:
> Hi,
> 
> This patch set introduces a new user API for tracking user memory pages
> that have not been used for a given period of time. The purpose of this
> is to provide the userspace with the means of tracking a workload's
> working set, i.e. the set of pages that are actively used by the
> workload. Knowing the working set size can be useful for partitioning
> the system more efficiently, e.g. by tuning memory cgroup limits
> appropriately, or for job placement within a compute cluster.
> 
> ---- USE CASES ----
> 
> The unified cgroup hierarchy has memory.low and memory.high knobs, which
> are defined as the low and high boundaries for the workload working set
> size. However, the working set size of a workload may be unknown or
> change in time. With this patch set, one can periodically estimate the
> amount of memory unused by each cgroup and tune their memory.low and
> memory.high parameters accordingly, therefore optimizing the overall
> memory utilization.
> 
> Another use case is balancing workloads within a compute cluster.
> Knowing how much memory is not really used by a workload unit may help
> take a more optimal decision when considering migrating the unit to
> another node within the cluster.

Another usecase I have a interest is working with per-process reclaim.
https://lwn.net/Articles/545668/
With idle tracking, we could reclaim idle pages only by smart user
memory-manager.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
