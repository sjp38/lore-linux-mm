Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 63B616B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 14:52:35 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id p10so864750wes.20
        for <linux-mm@kvack.org>; Thu, 29 May 2014 11:52:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id es20si3879899wic.55.2014.05.29.11.52.33
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 11:52:34 -0700 (PDT)
Date: Thu, 29 May 2014 15:46:49 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v3)
Message-ID: <20140529184649.GA20609@amt.cnet>
References: <20140523193706.GA22854@amt.cnet>
 <20140526185344.GA19976@amt.cnet>
 <53858A06.8080507@huawei.com>
 <20140528224324.GA1132@amt.cnet>
 <alpine.DEB.2.10.1405281838370.6096@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405281838370.6096@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


On Wed, May 28, 2014 at 06:45:04PM -0500, Christoph Lameter wrote:

<snip>

Much cleaner, sent v4 with your suggestions.

> Why call __alloc_pages_nodemask at all if you want to skip the node
> handling? Punt to alloc_pages()

- __alloc_pages_nodemask ignored GFP_DMA32 on older kernels, so the
interface should remain functional.
- There are others callers of alloc_pages(GFP_DMA) that can suffer
from the same problem.
- Mirrors mempolicy behaviour.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
