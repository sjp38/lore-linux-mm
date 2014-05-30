Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id AE2E06B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 17:44:35 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so2692016wes.15
        for <linux-mm@kvack.org>; Fri, 30 May 2014 14:44:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id eo20si7511089wid.19.2014.05.30.14.44.32
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 14:44:33 -0700 (PDT)
Date: Fri, 30 May 2014 18:43:45 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v4)
Message-ID: <20140530214344.GA14720@amt.cnet>
References: <20140523193706.GA22854@amt.cnet>
 <20140526185344.GA19976@amt.cnet>
 <53858A06.8080507@huawei.com>
 <20140528224324.GA1132@amt.cnet>
 <20140529184303.GA20571@amt.cnet>
 <alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
 <20140529161253.73ff978f723972f503123fe8@linux-foundation.org>
 <alpine.DEB.2.10.1405300841390.8240@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405300841390.8240@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>

On Fri, May 30, 2014 at 08:48:41AM -0500, Christoph Lameter wrote:
> On Thu, 29 May 2014, Andrew Morton wrote:
> 
> > >
> > > 	if (!nodemask && gfp_zone(gfp_mask) < policy_zone)
> > > 		nodemask = &node_states[N_ONLINE];
> >
> > OK, thanks, I made the patch go away for now.
> >
> 
> And another issue is that the policy_zone may be highmem on 32 bit
> platforms which will result in ZONE_NORMAL to be exempted.
> 
> policy zone can actually even be ZONE_DMA for some platforms. The
> check would not be useful at all on those.
> 
> Ignoring the containing cpuset only makes sense for GFP_DMA32 on
> 64 bit platforms and for GFP_DMA on platforms where there is an actual
> difference in the address spaces supported by GFP_DMA (such as x86).
> 
> Generally I think this is only useful for platforms that attempt to
> support legacy devices only able to DMA to a portion of the memory address
> space and that at the same time support NUMA for large address spaces.
> This is a contradiction on the one hand this is a high end system and on
> the other hand it attempts to support crippled DMA devices?

OK we will handle this in userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
