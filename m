Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 096126B0036
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 15:11:08 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so1446906qcy.28
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:11:07 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id m7si4780354qay.57.2014.07.11.12.11.06
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 12:11:06 -0700 (PDT)
Date: Fri, 11 Jul 2014 14:11:02 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140711182814.GE30865@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407111405280.5070@gentwo.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org> <alpine.DEB.2.11.1407111012210.25527@gentwo.org> <20140711152156.GB29137@htj.dyndns.org>
 <alpine.DEB.2.11.1407111056060.27349@gentwo.org> <20140711160152.GC30865@htj.dyndns.org> <alpine.DEB.2.11.1407111117560.27592@gentwo.org> <20140711162451.GD30865@htj.dyndns.org> <alpine.DEB.2.11.1407111220410.4511@gentwo.org>
 <20140711182814.GE30865@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Tejun Heo wrote:

> On Fri, Jul 11, 2014 at 12:29:30PM -0500, Christoph Lameter wrote:
> > GFP_THISNODE is mostly used by allocators that need memory from specific
> > nodes. The use of numa_mem_id() there is useful because one will not
> > get any memory at all when attempting to allocate from a memoryless
> > node using GFP_THISNODE.
>
> As long as it's in allocator proper, it doesn't matter all that much
> but the changes are clearly not contained, are they?

Well there is a proliferation of memory allocators recently. NUMA is often
a second thought in those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
