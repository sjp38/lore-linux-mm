Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id D4E7A900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:22:01 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id s7so990795qap.41
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:22:01 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id u6si3904343qad.22.2014.07.11.08.22.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 08:22:00 -0700 (PDT)
Received: by mail-qc0-f171.google.com with SMTP id w7so1106355qcr.2
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:22:00 -0700 (PDT)
Date: Fri, 11 Jul 2014 11:21:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Message-ID: <20140711152156.GB29137@htj.dyndns.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com>
 <20140711144205.GA27706@htj.dyndns.org>
 <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Jul 11, 2014 at 10:13:57AM -0500, Christoph Lameter wrote:
> Allocators typically fall back but they wont in some cases if you say
> that you want memory from a particular node. A GFP_THISNODE would force a
> failure of the alloc. In other cases it should fall back. I am not sure
> that all allocations obey these conventions though.

But, GFP_THISNODE + numa_mem_id() is identical to numa_node_id() +
nearest node with memory fallback.  Is there any case where the user
would actually want to always fail if it's on the memless node?

Even if that's the case, there's no reason to burden everyone with
this distinction.  Most users just wanna say "I'm on this node.
Please allocate considering that".  There's nothing wrong with using
numa_node_id() for that.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
