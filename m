Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E42D6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:24:00 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3220245pad.28
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:24:00 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id nv9si6064866pbb.35.2014.03.06.13.23.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:23:59 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id rr13so3178727pbb.25
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:23:59 -0800 (PST)
Date: Thu, 6 Mar 2014 13:23:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/11] userspace out of memory handling
In-Reply-To: <20140306211136.GA17902@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <20140306204923.GF14033@htj.dyndns.org> <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com> <20140306205911.GG14033@htj.dyndns.org> <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
 <20140306211136.GA17902@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 6 Mar 2014, Tejun Heo wrote:

> > I'm not sure how you reach that conclusion: it's necessary because any 
> > process handling the oom condition will need memory to do anything useful.  
> > How else would a process that is handling a system oom condition, for 
> > example, be able to obtain a list of processes, check memory usage, issue 
> > a kill, do any logging, collect heap or smaps samples, or signal processes 
> > to throttle incoming requests without having access to memory itself?  The 
> > system is oom.
> 
> We're now just re-starting the whole discussion with all context lost.
> How is this a good idea?  We talked about all this previously.  If you
> have something to add, add there *please* so that other people can
> track it too.
> 

I'm referring to system oom handling as an example above, in case you 
missed my earlier email a few minutes ago: the previous patchset did not 
include support for system oom handling.  Nothing that I wrote above was 
possible with the first patchset.  This is the complete support.

> That's completely fine but if that's your intention please at least
> prefix the patchset with RFC and explicitly state that no consensus
> has been reached (well, it was more like negative consensus from what
> I remember) in the description so that it can't be picked up
> accidentally.
> 

This patchset provides a solution to a real-world problem that is not 
solved with any other patchset.  I expect it to be reviewed as any other 
patchset, it's not an "RFC" from my perspective: it's a proposal for 
inclusion.  Don't worry, Andrew is not going to apply anything 
accidentally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
