Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 99B236B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:50:59 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id la4so2113553vcb.29
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:50:59 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id uk3si3044544vec.102.2014.05.30.06.50.58
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 06:50:59 -0700 (PDT)
Date: Fri, 30 May 2014 08:50:56 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v5)
In-Reply-To: <alpine.DEB.2.02.1405291638300.9336@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1405300849190.8240@gentwo.org>
References: <20140523193706.GA22854@amt.cnet> <20140526185344.GA19976@amt.cnet> <53858A06.8080507@huawei.com> <20140528224324.GA1132@amt.cnet> <20140529184303.GA20571@amt.cnet> <alpine.DEB.2.02.1405291555120.9336@chino.kir.corp.google.com>
 <20140529232819.GA29803@amt.cnet> <alpine.DEB.2.02.1405291638300.9336@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 29 May 2014, David Rientjes wrote:

> When I said that my point about mempolicies needs more thought, I wasn't
> expecting that there would be no discussion -- at least _something_ that
> would say why we don't care about the mempolicy case.

Lets get Andi involved here too.

> The motivation here is identical for both cpusets and mempolicies.  What
> is the significant difference between attaching a process to a cpuset
> without access to lowmem and a process doing set_mempolicy(MPOL_BIND)
> without access to lowmem?  Is it because the process should know what it's
> doing if it asks for a mempolicy that doesn't include lowmem?  If so, is
> the cpusets case different because the cpuset attacher isn't held to the
> same standard?
>
> I'd argue that an application may never know if it needs to allocate
> GFP_DMA32 or not since its a property of the hardware that its running on
> and my driver may need to access lowmem while yours may not.  I may even
> configure CONFIG_ZONE_DMA=n and CONFIG_ZONE_DMA32=n because I know the
> _hardware_ requirements of my platforms.

Right. This is a hardware issue and the hardware is pretty messed up. And
now one wants to use NUMA features?

> If there is no difference, then why are we allowing the exception for
> cpusets and not mempolicies?
>
> I really think you want to allow both cpusets and mempolicies.  I'd like
> to hear Christoph's thoughts on it as well, though.

I said something elsewhere in the thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
