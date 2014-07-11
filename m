Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCB06B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:01:57 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id id10so2421095vcb.24
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:01:56 -0700 (PDT)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id pw10si1907243vec.96.2014.07.11.09.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 09:01:56 -0700 (PDT)
Received: by mail-qa0-f52.google.com with SMTP id j15so1039728qaq.39
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:01:55 -0700 (PDT)
Date: Fri, 11 Jul 2014 12:01:52 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711160152.GC30865@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
 <20140711144205.GA27706@htj.dyndns.org>
 <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
 <20140711152156.GB29137@htj.dyndns.org>
 <alpine.DEB.2.11.1407111056060.27349@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111056060.27349@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 10:58:52AM -0500, Christoph Lameter wrote:
> > But, GFP_THISNODE + numa_mem_id() is identical to numa_node_id() +
> > nearest node with memory fallback.  Is there any case where the user
> > would actually want to always fail if it's on the memless node?
> 
> GFP_THISNODE allocatios must fail if there is no memory available on
> the node. No fallback allowed.

I don't know.  The intention is that the caller wants something on
this node or the caller will fail or fallback ourselves, right?  For
most use cases just considering the nearest memory node as "local" for
memless nodes should work and serve the intentions of the users close
enough.  Whether that'd be better or we'd be better off with something
else depends on the details for sure.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
