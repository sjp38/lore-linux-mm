Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 113FF6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:13:41 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id i8so3742112qcq.31
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:13:40 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id a10si1147377qcs.2.2014.03.06.13.13.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:13:40 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id cm18so3040659qab.22
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:13:40 -0800 (PST)
Date: Thu, 6 Mar 2014 16:13:37 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 09/11] mm, page_alloc: allow system oom handlers to use
 memory reserves
Message-ID: <20140306211337.GC17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1403041956510.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041956510.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:59:35PM -0800, David Rientjes wrote:
> The root memcg allows unlimited memory charging, so no memory may be
> reserved for userspace oom handlers that are responsible for dealing
> with system oom conditions.
> 
> Instead, this memory must come from per-zone memory reserves.  This
> allows the memory allocation to succeed, and the memcg charge will
> naturally succeed afterwards.
> 
> This patch introduces per-zone oom watermarks that aren't really
> watermarks in the traditional sense.  The oom watermark is the root
> memcg's oom reserve proportional to the size of the zone.  When a page
> allocation is done, the effective watermark is
> 
> 	[min/low/high watermark] - [oom watermark]
> 
> For the [min watermark] case, this is effectively the oom reserve.
> However, it also adjusts the low and high watermark accordingly so
> memory is actually only allocated from min reserves when appropriate.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Until consensus on the whole approach can be reached,

 Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
