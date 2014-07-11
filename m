Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id D29F76B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:19:20 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id r5so372221qcx.13
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:19:20 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id x9si3892898qax.121.2014.07.11.09.19.18
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 09:19:19 -0700 (PDT)
Date: Fri, 11 Jul 2014 11:19:14 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140711160152.GC30865@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407111117560.27592@gentwo.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org> <alpine.DEB.2.11.1407111012210.25527@gentwo.org> <20140711152156.GB29137@htj.dyndns.org>
 <alpine.DEB.2.11.1407111056060.27349@gentwo.org> <20140711160152.GC30865@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Tejun Heo wrote:

> On Fri, Jul 11, 2014 at 10:58:52AM -0500, Christoph Lameter wrote:
> > > But, GFP_THISNODE + numa_mem_id() is identical to numa_node_id() +
> > > nearest node with memory fallback.  Is there any case where the user
> > > would actually want to always fail if it's on the memless node?
> >
> > GFP_THISNODE allocatios must fail if there is no memory available on
> > the node. No fallback allowed.
>
> I don't know.  The intention is that the caller wants something on
> this node or the caller will fail or fallback ourselves, right?  For
> most use cases just considering the nearest memory node as "local" for
> memless nodes should work and serve the intentions of the users close
> enough.  Whether that'd be better or we'd be better off with something
> else depends on the details for sure.

Yes that works. But if we want a consistent node to allocate from (and
avoid the fallbacks) then we need this patch. I think this is up to those
needing memoryless nodes to figure out what semantics they need.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
