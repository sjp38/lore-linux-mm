Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id E30666B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:11:40 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id r5so3599751qcx.4
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:11:40 -0800 (PST)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id s49si3239894qge.66.2014.03.06.13.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:11:40 -0800 (PST)
Received: by mail-qc0-f170.google.com with SMTP id e9so3738735qcy.29
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:11:40 -0800 (PST)
Date: Thu, 6 Mar 2014 16:11:36 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140306211136.GA17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <20140306204923.GF14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
 <20140306205911.GG14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

Hello, David.

On Thu, Mar 06, 2014 at 01:08:10PM -0800, David Rientjes wrote:
> I'm not sure how you reach that conclusion: it's necessary because any 
> process handling the oom condition will need memory to do anything useful.  
> How else would a process that is handling a system oom condition, for 
> example, be able to obtain a list of processes, check memory usage, issue 
> a kill, do any logging, collect heap or smaps samples, or signal processes 
> to throttle incoming requests without having access to memory itself?  The 
> system is oom.

We're now just re-starting the whole discussion with all context lost.
How is this a good idea?  We talked about all this previously.  If you
have something to add, add there *please* so that other people can
track it too.

> This is going to be discussed at the LSF/mm conference, I believe it would 
> be helpful to have an actual complete patchset proposed so that it can be 
> discussed properly.  I feel no need to refer to an older patchset that 
> would not apply and did not include all the support necessary for handling 
> oom conditions.

That's completely fine but if that's your intention please at least
prefix the patchset with RFC and explicitly state that no consensus
has been reached (well, it was more like negative consensus from what
I remember) in the description so that it can't be picked up
accidentally.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
