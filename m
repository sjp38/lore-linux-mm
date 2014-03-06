Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id A67556B0036
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:12:50 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 142so8218172ykq.0
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:12:50 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id 69si12423255yhf.97.2014.03.06.13.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:12:50 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id f73so3365428yha.28
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:12:50 -0800 (PST)
Date: Thu, 6 Mar 2014 16:12:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 07/11] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20140306211246.GB17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1403041956040.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041956040.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:59:29PM -0800, David Rientjes wrote:
> Now that a per-process flag is available, define it for processes that
> handle userspace oom notifications.  This is an optimization to avoid
> mantaining a list of such processes attached to a memcg at any given time
> and iterating it at charge time.
> 
> This flag gets set whenever a process has registered for an oom
> notification and is cleared whenever it unregisters.
> 
> When memcg reclaim has failed to free any memory, it is necessary for
> userspace oom handlers to be able to dip into reserves to pagefault text,
> allocate kernel memory to read the "tasks" file, allocate heap, etc.
> 
> System oom conditions are not addressed at this time, but the same per-
> process flag can be used in the page allocator to determine if access
> should be given to userspace oom handlers to per-zone memory reserves at
> a later time once there is consensus.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

ntil consensus on the whole approach can be reached,

 Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
