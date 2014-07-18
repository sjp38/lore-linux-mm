Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id C5EA06B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:20:42 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j7so2923830qaq.28
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:20:42 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id f94si9895396qgd.22.2014.07.18.04.20.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 04:20:42 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so2939353qaq.29
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 04:20:41 -0700 (PDT)
Date: Fri, 18 Jul 2014 07:20:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-ID: <20140718112039.GA8383@htj.dyndns.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140717230923.GA32660@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Thu, Jul 17, 2014 at 04:09:23PM -0700, Nishanth Aravamudan wrote:
> [Apologies for the large Cc list, but I believe we have the following
> interested parties:
> 
> x86 (recently posted memoryless node support)
> ia64 (existing memoryless node support)
> ppc (existing memoryless node support)
> previous discussion of how to solve Anton's issue with slab usage
> workqueue contributors/maintainers]

Well, you forgot to cc me.

...
> It turns out we see this large slab usage due to using the wrong NUMA
> information when creating kthreads.
>     
> Two changes are required, one of which is in the workqueue code and one
> of which is in the powerpc initialization. Note that ia64 may want to
> consider something similar.

Wasn't there a thread on this exact subject a few weeks ago?  Was that
someone else?  Memory-less node detail leaking out of allocator proper
isn't a good idea.  Please allow allocator users to specify the nodes
they're on and let the allocator layer deal with mapping that to
whatever is appropriate.  Please don't push that to everybody.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
