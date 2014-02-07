Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 695D26B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:22:04 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so5492552qae.10
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:22:04 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id k93si3767783qgf.5.2014.02.07.07.22.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 07:22:02 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id e16so6065308qcx.21
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:22:02 -0800 (PST)
Date: Fri, 7 Feb 2014 10:21:58 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140207152158.GC3304@htj.dyndns.org>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 06, 2014 at 03:56:01PM -0800, Hugh Dickins wrote:
> Sometimes the cleanup after memcg hierarchy testing gets stuck in
> mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> 
> There may turn out to be several causes, but a major cause is this: the
> workitem to offline parent can get run before workitem to offline child;
> parent's mem_cgroup_reparent_charges() circles around waiting for the
> child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> which prevents the child from reaching its mem_cgroup_reparent_charges().
> 
> Just use an ordered workqueue for cgroup_destroy_wq.
> 
> Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
> Suggested-by: Filipe Brandenburger <filbranden@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # 3.10+

Applied to cgroup/for-3.14-fixes with comment updated to indicate that
this is temporary.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
