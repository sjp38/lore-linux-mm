Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 350476B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:33:28 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so367850yha.12
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:33:28 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id t51si12522496yhg.100.2014.03.06.13.33.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:33:27 -0800 (PST)
Received: by mail-yk0-f171.google.com with SMTP id q9so8281009ykb.2
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:33:27 -0800 (PST)
Date: Thu, 6 Mar 2014 16:33:24 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140306213324.GG17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <20140306204923.GF14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
 <20140306205911.GG14033@htj.dyndns.org>
 <alpine.DEB.2.02.1403061301020.25499@chino.kir.corp.google.com>
 <20140306211136.GA17902@htj.dyndns.org>
 <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403061312020.25499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

A bit of addition.

On Thu, Mar 06, 2014 at 01:23:57PM -0800, David Rientjes wrote:
> This patchset provides a solution to a real-world problem that is not 
> solved with any other patchset.  I expect it to be reviewed as any other 
> patchset, it's not an "RFC" from my perspective: it's a proposal for 
> inclusion.  Don't worry, Andrew is not going to apply anything 
> accidentally.

I can't force it down your throat but I feel somewhat uneasy about how
this was posted without any reference to the previous discussion as if
this were just now being proposed especially as the said discussion
wasn't particularly favorable to this approach.  Prefixing RFC or at
least pointing back to the original discussion seems like the
courteous thing to do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
