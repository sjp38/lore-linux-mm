Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF37D6B02AE
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 04:49:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d8so15802802pgt.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 01:49:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si6390796plv.549.2017.09.11.01.49.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 01:49:35 -0700 (PDT)
Date: Mon, 11 Sep 2017 10:49:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170911084931.zezai6aufcfi2ddt@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <alpine.DEB.2.20.1709071114560.20082@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709071114560.20082@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 07-09-17 11:18:18, Cristopher Lameter wrote:
> On Mon, 4 Sep 2017, Roman Gushchin wrote
> 
> > To address these issues, cgroup-aware OOM killer is introduced.
> 
> You are missing a major issue here. Processes may have allocation
> constraints to memory nodes, special DMA zones etc etc. OOM conditions on
> such resource constricted allocations need to be dealt with. Killing
> processes that do not allocate with the same restrictions may not do
> anything to improve conditions.

memcg_oom_badness tries to be node aware - very similar to what the
oom_badness does for the regular oom killer. Or do you have anything
else in mind?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
