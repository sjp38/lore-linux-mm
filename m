Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id E16306B003B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:14:03 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id r5so284644qcx.13
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:14:03 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id i80si1747499qge.92.2014.07.11.08.14.02
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 08:14:03 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:13:57 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140711144205.GA27706@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Tejun Heo wrote:

> Hello,
>
> On Fri, Jul 11, 2014 at 03:37:24PM +0800, Jiang Liu wrote:
> > When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> > may return a node without memory, and later cause system failure/panic
> > when calling kmalloc_node() and friends with returned node id.
>
> The patch itself looks okay to me but is this the right way to handle
> this?  Can't we just let the allocators fall back to the nearest node
> with memory?  Why do we need to impose this awareness of memory-less
> node on all the users?

Allocators typically fall back but they wont in some cases if you say
that you want memory from a particular node. A GFP_THISNODE would force a
failure of the alloc. In other cases it should fall back. I am not sure
that all allocations obey these conventions though.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
