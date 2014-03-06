Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 79B5C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:04:31 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so326562yha.40
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:04:31 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id m69si12394180yhb.85.2014.03.06.13.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:04:30 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id t59so3299853yho.37
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:04:30 -0800 (PST)
Date: Thu, 6 Mar 2014 16:04:27 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 04/11] mm, memcg: add tunable for oom reserves
Message-ID: <20140306210427.GH14033@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:59:19PM -0800, David Rientjes wrote:
> Userspace needs a way to define the amount of memory reserves that
> processes handling oom conditions may utilize.  This patch adds a per-
> memcg oom reserve field and file, memory.oom_reserve_in_bytes, to
> manipulate its value.
> 
> If currently utilized memory reserves are attempted to be reduced by
> writing a smaller value to memory.oom_reserve_in_bytes, it will fail with
> -EBUSY until some memory is uncharged.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

We're completely unsure this is the way we wanna be headed and this is
a huge commitment.  For now at least,

Nacked-by: Tejun Heo <tj@kernel.org>

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
