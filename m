Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id B106D6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:24:56 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id a108so1039781qge.24
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:24:56 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id i20si4156790qgd.66.2014.07.11.09.24.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 09:24:55 -0700 (PDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so1125799qgd.5
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:24:55 -0700 (PDT)
Date: Fri, 11 Jul 2014 12:24:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711162451.GD30865@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
 <20140711144205.GA27706@htj.dyndns.org>
 <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
 <20140711152156.GB29137@htj.dyndns.org>
 <alpine.DEB.2.11.1407111056060.27349@gentwo.org>
 <20140711160152.GC30865@htj.dyndns.org>
 <alpine.DEB.2.11.1407111117560.27592@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111117560.27592@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 11:19:14AM -0500, Christoph Lameter wrote:
> Yes that works. But if we want a consistent node to allocate from (and
> avoid the fallbacks) then we need this patch. I think this is up to those
> needing memoryless nodes to figure out what semantics they need.

I'm not following what you're saying.  Are you saying that we need to
spread numa_mem_id() all over the place for GFP_THISNODE users on
memless nodes?  There aren't that many users of GFP_THISNODE.
Wouldn't it make far more sense to just change them?  Or just
introduce a new GFP flag GFP_CLOSE_OR_BUST which allows falling back
to the nearest local node for memless nodes.  There's no reason to
leak this information outside allocator proper.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
