Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CE10F6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:08:41 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so3171797pad.16
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:08:41 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id m9si6086870pab.119.2014.03.06.13.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:08:40 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id lf10so3196092pab.13
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:08:13 -0800 (PST)
Date: Thu, 6 Mar 2014 13:08:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/11] userspace out of memory handling
In-Reply-To: <20140306205911.GG14033@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <20140306204923.GF14033@htj.dyndns.org> <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com> <20140306205911.GG14033@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 6 Mar 2014, Tejun Heo wrote:

> > This includes system oom handling alongside memcg oom handling.  If you 
> > have specific objections, please let us know, thanks!
> 
> Umm, that wasn't the bulk of objection, was it?  We were discussion
> the whole premise of userland oom handling and the conclusion, at
> best, was that you couldn't show that it was actually necessary and
> most other people disliked the idea.

I'm not sure how you reach that conclusion: it's necessary because any 
process handling the oom condition will need memory to do anything useful.  
How else would a process that is handling a system oom condition, for 
example, be able to obtain a list of processes, check memory usage, issue 
a kill, do any logging, collect heap or smaps samples, or signal processes 
to throttle incoming requests without having access to memory itself?  The 
system is oom.

> Just changing a part of it and
> resubmitting doesn't really change the whole situation.  If you want
> to continue the discussion on the basic approach, please do continue
> that on the original thread so that we don't lose the context.  I'm
> gonna nack the respective patches so that they don't get picked up by
> accident for now.
> 

This is going to be discussed at the LSF/mm conference, I believe it would 
be helpful to have an actual complete patchset proposed so that it can be 
discussed properly.  I feel no need to refer to an older patchset that 
would not apply and did not include all the support necessary for handling 
oom conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
