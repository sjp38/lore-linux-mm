Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id D65F36B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 15:59:15 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so3662688qcv.33
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:59:15 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id b79si3817318qge.29.2014.03.06.12.59.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 12:59:15 -0800 (PST)
Received: by mail-qg0-f47.google.com with SMTP id 63so8807365qgz.6
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:59:15 -0800 (PST)
Date: Thu, 6 Mar 2014 15:59:11 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140306205911.GG14033@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <20140306204923.GF14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, Mar 06, 2014 at 12:55:43PM -0800, David Rientjes wrote:
> > ISTR the conclusion last time was nack on the whole approach.  What
> > changed between then and now?  I can't detect any fundamental changes
> > from the description.
> > 
> 
> This includes system oom handling alongside memcg oom handling.  If you 
> have specific objections, please let us know, thanks!

Umm, that wasn't the bulk of objection, was it?  We were discussion
the whole premise of userland oom handling and the conclusion, at
best, was that you couldn't show that it was actually necessary and
most other people disliked the idea.  Just changing a part of it and
resubmitting doesn't really change the whole situation.  If you want
to continue the discussion on the basic approach, please do continue
that on the original thread so that we don't lose the context.  I'm
gonna nack the respective patches so that they don't get picked up by
accident for now.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
