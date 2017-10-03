Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1862E6B0069
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:50:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so3901617wmd.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:50:58 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x90si8966729edc.303.2017.10.03.05.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 05:50:57 -0700 (PDT)
Date: Tue, 3 Oct 2017 13:50:27 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v9 2/5] mm: implement mem_cgroup_scan_tasks() for the root
 memory cgroup
Message-ID: <20171003125027.GB28904@castle.DHCP.thefacebook.com>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-3-guro@fb.com>
 <20171003104939.vm7pezgef7bqxe2v@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171003104939.vm7pezgef7bqxe2v@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 12:49:39PM +0200, Michal Hocko wrote:
> On Wed 27-09-17 14:09:33, Roman Gushchin wrote:
> > Implement mem_cgroup_scan_tasks() functionality for the root
> > memory cgroup to use this function for looking for a OOM victim
> > task in the root memory cgroup by the cgroup-ware OOM killer.
> > 
> > The root memory cgroup should be treated as a leaf cgroup,
> > so only tasks which are directly belonging to the root cgroup
> > should be iterated over.
> 
> I would only add that this patch doesn't introduce any functionally
> visible change because we never trigger oom killer with the root memcg
> as the root of the hierarchy. So this is just a preparatory work for
> later changes.

Sure, thanks!

> 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: kernel-team@fb.com
> > Cc: cgroups@vger.kernel.org
> > Cc: linux-doc@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
