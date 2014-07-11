Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD936B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:58:43 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so1097358qge.18
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:58:43 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id l4si4038250qch.19.2014.07.11.08.58.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 08:58:42 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id j107so1150230qga.31
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:58:41 -0700 (PDT)
Date: Fri, 11 Jul 2014 11:58:38 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711155838.GB30865@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
 <20140711144205.GA27706@htj.dyndns.org>
 <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
 <20140711152156.GB29137@htj.dyndns.org>
 <20140711153302.GA30865@htj.dyndns.org>
 <alpine.DEB.2.11.1407111054190.27349@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111054190.27349@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 10:55:59AM -0500, Christoph Lameter wrote:
> > Where X is the memless node.  num_mem_id() on X would return either B
> > or C, right?  If B or C can't satisfy the allocation, the allocator
> > would fallback to A from B and D for C, both of which aren't optimal.
> > It should first fall back to C or B respectively, which the allocator
> > can't do anymoe because the information is lost when the caller side
> > performs numa_mem_id().
> 
> True but the advantage is that the numa_mem_id() allows the use of a
> consitent sort of "local" node which increases allocator performance due
> to the abillity to cache objects from that node.

But the allocator can do the mapping the same.  I really don't see why
we'd push the distinction to the individual users.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
