Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E53A6B0003
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:11:48 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id v195so4935545qka.10
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 11:11:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d132sor8658047qkc.4.2018.01.29.11.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 11:11:42 -0800 (PST)
Date: Mon, 29 Jan 2018 11:11:39 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180129191139.GA1121507@devbig577.frc2.facebook.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
 <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
 <20180129104657.GC21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129104657.GC21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Michal.

On Mon, Jan 29, 2018 at 11:46:57AM +0100, Michal Hocko wrote:
> @@ -1292,7 +1292,11 @@ the memory controller considers only cgroups belonging to the sub-tree
>  of the OOM'ing cgroup.
>  
>  The root cgroup is treated as a leaf memory cgroup, so it's compared
> -with other leaf memory cgroups and cgroups with oom_group option set.
> +with other leaf memory cgroups and cgroups with oom_group option
> +set. Due to internal implementation restrictions the size of the root
> +cgroup is a cumulative sum of oom_badness of all its tasks (in other
> +words oom_score_adj of each task is obeyed). This might change in the
> +future.

Thanks, we can definitely use more documentation.  However, it's a bit
difficult to follow.  Maybe expand it to a separate paragraph on the
current behavior with a clear warning that the default OOM heuristics
is subject to changes?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
