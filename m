Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2796B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 14:28:20 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so1273718qgd.33
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:28:19 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id 33si4681791qgj.49.2014.07.11.11.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 11:28:18 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id f12so1078522qad.17
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:28:17 -0700 (PDT)
Date: Fri, 11 Jul 2014 14:28:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711182814.GE30865@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
 <20140711144205.GA27706@htj.dyndns.org>
 <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
 <20140711152156.GB29137@htj.dyndns.org>
 <alpine.DEB.2.11.1407111056060.27349@gentwo.org>
 <20140711160152.GC30865@htj.dyndns.org>
 <alpine.DEB.2.11.1407111117560.27592@gentwo.org>
 <20140711162451.GD30865@htj.dyndns.org>
 <alpine.DEB.2.11.1407111220410.4511@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111220410.4511@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Jul 11, 2014 at 12:29:30PM -0500, Christoph Lameter wrote:
> GFP_THISNODE is mostly used by allocators that need memory from specific
> nodes. The use of numa_mem_id() there is useful because one will not
> get any memory at all when attempting to allocate from a memoryless
> node using GFP_THISNODE.

As long as it's in allocator proper, it doesn't matter all that much
but the changes are clearly not contained, are they?

Also, unless this is done where the falling back is actually
happening, numa_mem_id() seems like the wrong interface because you
end up losing information of the originating node.  Given that this
isn't a wide spread use case, maybe we can do with something like
numa_mem_id() as a compromise but if we're doing that let's at least
make it clear that it's something ugly (give it an ugly name, not
something as generic as numa_mem_id()) and not expose it outside
allocators.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
