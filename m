Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B7BC86B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 23:17:04 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so796733pad.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 20:17:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qn15si930258pab.176.2014.07.22.20.17.03
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 20:17:03 -0700 (PDT)
Message-ID: <53CF2925.3030803@linux.intel.com>
Date: Wed, 23 Jul 2014 11:16:53 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to support
 memoryless node
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org> <alpine.DEB.2.11.1407111012210.25527@gentwo.org> <20140711152156.GB29137@htj.dyndns.org> <alpine.DEB.2.11.1407111056060.27349@gentwo.org> <20140711160152.GC30865@htj.dyndns.org> <alpine.DEB.2.11.1407111117560.27592@gentwo.org> <20140711162451.GD30865@htj.dyndns.org> <alpine.DEB.2.11.1407111220410.4511@gentwo.org> <20140711182814.GE30865@htj.dyndns.org> <alpine.DEB.2.11.1407111405280.5070@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407111405280.5070@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tejun and Christoph,
	Thanks for your suggestions and discussion. Tejun really
gives a good point to hide memoryless node interface from normal
slab users. I will rework the patch set to go that direction.
Regards!
Gerry

On 2014/7/12 3:11, Christoph Lameter wrote:
> On Fri, 11 Jul 2014, Tejun Heo wrote:
> 
>> On Fri, Jul 11, 2014 at 12:29:30PM -0500, Christoph Lameter wrote:
>>> GFP_THISNODE is mostly used by allocators that need memory from specific
>>> nodes. The use of numa_mem_id() there is useful because one will not
>>> get any memory at all when attempting to allocate from a memoryless
>>> node using GFP_THISNODE.
>>
>> As long as it's in allocator proper, it doesn't matter all that much
>> but the changes are clearly not contained, are they?
> 
> Well there is a proliferation of memory allocators recently. NUMA is often
> a second thought in those.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
