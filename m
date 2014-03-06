Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 343246B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:15:11 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so3603559qcv.19
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:15:11 -0800 (PST)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id 4si3824384qat.98.2014.03.06.13.15.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:15:10 -0800 (PST)
Received: by mail-qg0-f44.google.com with SMTP id a108so8910728qge.3
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:15:10 -0800 (PST)
Date: Thu, 6 Mar 2014 16:15:06 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 10/11] mm, memcg: add memory.oom_control notification for
 system oom
Message-ID: <20140306211506.GD17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1403041957140.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041957140.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:59:41PM -0800, David Rientjes wrote:
> Now that process handling system oom conditions have access to a small
> amount of memory reserves, we need a way to notify those process on
> system oom conditions.
> 
> When a userspace process waits on the root memcg's memory.oom_control, it
> will wake up anytime there is a system oom condition.
> 
> This is a special case of oom notifiers since it doesn't subsequently
> notify all memcgs under the root memcg (all memcgs on the system).  We
> don't want to trigger those oom handlers which are set aside specifically
> for true memcg oom notifications that disable their own oom killers to
> enforce their own oom policy, for example.
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
