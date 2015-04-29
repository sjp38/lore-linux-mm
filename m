Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 316766B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 23:58:12 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so15879697pdb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 20:58:11 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id pj8si37599221pdb.46.2015.04.28.20.58.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 20:58:10 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so15879078pdb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 20:58:10 -0700 (PDT)
Date: Wed, 29 Apr 2015 12:57:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 0/3] idle memory tracking
Message-ID: <20150429035722.GA11486@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1430217477.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello Vladimir,

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
> 
> ---- USER API ----
> 
> The user API consists of two new proc files:
> 
>  * /proc/kpageidle.  For each page this file contains a 64-bit number, which
>    equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is

Why do we need 64bit per page to indicate just idle or not?
What do you imagine we're happy with other 63bit in future?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
