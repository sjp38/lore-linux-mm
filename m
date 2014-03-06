Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id B08C76B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 15:49:28 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id i50so4447450qgf.0
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:49:28 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id h93si3777104qgh.104.2014.03.06.12.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 12:49:27 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id w7so3577389qcr.22
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:49:27 -0800 (PST)
Date: Thu, 6 Mar 2014 15:49:23 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-ID: <20140306204923.GF14033@htj.dyndns.org>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, Mar 04, 2014 at 07:58:38PM -0800, David Rientjes wrote:
> This patchset implements userspace out of memory handling.
> 
> It is based on v3.14-rc5.  Individual patches will apply cleanly or you
> may pull the entire series from
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/rientjes/linux.git mm/oom
> 
> When the system or a memcg is oom, processes running on that system or
> attached to that memcg cannot allocate memory.  It is impossible for a
> process to reliably handle the oom condition from userspace.

ISTR the conclusion last time was nack on the whole approach.  What
changed between then and now?  I can't detect any fundamental changes
from the description.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
