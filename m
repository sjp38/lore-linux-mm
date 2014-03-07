Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 28D576B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:21:05 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so4247833pdi.5
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:21:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id tu7si8932707pac.193.2014.03.07.09.21.03
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:21:04 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 03/11] mm, mempolicy: remove per-process flag
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1403041954420.8067@chino.kir.corp.google.com>
Date: Fri, 07 Mar 2014 09:20:39 -0800
In-Reply-To: <alpine.DEB.2.02.1403041954420.8067@chino.kir.corp.google.com>
	(David Rientjes's message of "Tue, 4 Mar 2014 19:59:16 -0800 (PST)")
Message-ID: <877g866i3c.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

David Rientjes <rientjes@google.com> writes:
>
> Per-process flags are a scarce resource so we should free them up
> whenever possible and make them available.  We'll be using it shortly for
> memcg oom reserves.

I'm not convinced TCP_RR is a meaningfull benchmark for slab.

The shortness seems like an artificial problem.

Just add another flag word to the task_struct? That would seem 
to be the obvious way. People will need it sooner or later anyways.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
