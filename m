Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 773326B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:15:33 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id q108so8883478qgd.10
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:15:33 -0800 (PST)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id u4si3836954qat.44.2014.03.06.13.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 13:15:33 -0800 (PST)
Received: by mail-qg0-f44.google.com with SMTP id a108so8912064qge.3
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:15:32 -0800 (PST)
Date: Thu, 6 Mar 2014 16:15:29 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 11/11] mm, memcg: allow system oom killer to be disabled
Message-ID: <20140306211529.GE17902@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1403041957340.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041957340.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:59:46PM -0800, David Rientjes wrote:
> Now that system oom conditions can properly be handled from userspace,
> allow the oom killer to be disabled.  Otherwise, the kernel will
> immediately kill a process and memory will be freed.  The userspace oom
> handler may have a different policy.
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
