Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id B82556B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 10:42:10 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so954525qae.6
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 07:42:10 -0700 (PDT)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id a50si3803559qgf.6.2014.07.11.07.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 07:42:09 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so932771qac.5
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 07:42:08 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:42:05 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711144205.GA27706@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Jul 11, 2014 at 03:37:24PM +0800, Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.

The patch itself looks okay to me but is this the right way to handle
this?  Can't we just let the allocators fall back to the nearest node
with memory?  Why do we need to impose this awareness of memory-less
node on all the users?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
