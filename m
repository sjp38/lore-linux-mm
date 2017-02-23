Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8596B0388
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:09:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e15so3950407wmd.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:09:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p44si1469468wrb.57.2017.02.23.11.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 11:09:10 -0800 (PST)
Date: Thu, 23 Feb 2017 14:03:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/2] mm/cgroup: delay soft limit data allocation
Message-ID: <20170223190313.GB6088@cmpxchg.org>
References: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487856999-16581-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170223153107.GD29056@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170223153107.GD29056@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2017 at 04:31:07PM +0100, Michal Hocko wrote:
> On Thu 23-02-17 14:36:39, Laurent Dufour wrote:
> > Until a soft limit is set to a cgroup, the soft limit data are useless
> > so delay this allocation when a limit is set.
> 
> Hmm, I am still undecided whether this is actually worth it. On one hand
> distribution kernels tend to have quite large NUMA_SHIFT (e.g. SLES has
> NUMA_SHIFT=10 and then we will save 8kB+12kB which is not hell of a lot
> but always good if we can save that, especially for a rarely used
> feature. The code grown on the other hand (it was in __init section
> previously) which is a minus, on the other hand.
> 
> What do you think Johannes?

Hohumm, saving 5 pages on a NUMA machine vs. the additional complexity
and the increased risk of memory problems when somebody sets up a soft
limit after some uptime... I don't think I can give a strong yes or no
on this one, so inertia wins for me; I'd just leave it alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
