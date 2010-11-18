Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B227A6B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:30:01 -0500 (EST)
Message-ID: <4CE4C7E4.50402@kernel.org>
Date: Thu, 18 Nov 2010 07:29:56 +0100
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: remove gfp mask from pcpu_get_vm_areas
References: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com> <alpine.DEB.2.00.1011161937380.19230@chino.kir.corp.google.com> <4CE39B89.8010908@kernel.org> <alpine.DEB.2.00.1011171229040.30790@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1011171229040.30790@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 11/17/2010 09:32 PM, David Rientjes wrote:
> A recent thread[*] shows a problem whereas gfp masks may be passed into 
> the vmalloc interface that restrict reclaim behavior, yet the underlying 
> pte allocator unconditionally uses GFP_KERNEL.  This is a first-pass at an 
> effort to remove all gfp_t formals from the vmalloc interface (and can be 
> completed once gfs2, ntfs, and ceph have converted) and require them to 
> use GFP_KERNEL.

I see.

> Luckily for the per-cpu allocator, this was trivial since that happens to 
> be the only use case already.

per-cpu allocator intentionally only allowed GFP_KERNEL till now.
There were some requests about allowing GFP_ATOMIC allocations and
that's the reason why the @gfp is there for the vm function.  Anyways,
this looks like the nail in that coffin.

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
