Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CDE676B005D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:47:32 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so4250112dad.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 12:47:32 -0700 (PDT)
Date: Thu, 18 Oct 2012 12:47:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 04/14] kmem accounting basic infrastructure
Message-ID: <20121018194727.GB13370@google.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
 <1350382611-20579-5-git-send-email-glommer@parallels.com>
 <alpine.DEB.2.00.1210171455010.20712@chino.kir.corp.google.com>
 <508035E3.4080508@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508035E3.4080508@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>

Hey, Glauber.

On Thu, Oct 18, 2012 at 09:01:23PM +0400, Glauber Costa wrote:
> That is the offensive part. But it is also how things are done in memcg
> right now, and there is nothing fundamentally different in this one.
> Whatever lands in the remaining offenders, can land in here.

I think the problem here is that we don't have "you're committing to
creation of a new cgroup" callback and thus subsystem can't
synchronize locally against cgroup creation.  For task migration
->attach() does that but cgroup creation may fail after ->create()
succeeded so that doesn't work.

We'll probably need to add ->post_create() which is invoked after
creation is complete.  Li?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
