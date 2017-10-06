Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87D9C6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 01:43:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c42so4234177wrc.13
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 22:43:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si558668wrv.418.2017.10.05.22.43.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 22:43:27 -0700 (PDT)
Date: Fri, 6 Oct 2017 07:43:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171006054325.uefqqiox4jzsjhjl@dhcp22.suse.cz>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
 <20171004204153.GA2696@cmpxchg.org>
 <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
 <20171005104429.GB12982@castle.dhcp.TheFacebook.com>
 <alpine.DEB.2.10.1710051453590.87457@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710051453590.87457@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 15:02:18, David Rientjes wrote:
[...]
> I would need to add patches to add the "evaluate as a whole but do not 
> kill all" knob and a knob for "oom priority" so that userspace has the 
> same influence over a cgroup based comparison that it does with a process 
> based comparison to meet business goals.

I do not think 2 knobs would be really necessary for your usecase. If we
allow priorities on non-leaf memcgs then a non 0 priority on such a
memcg would mean that we have to check the cumulative consumption. You
can safely use kill all knob on top of that if you need.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
