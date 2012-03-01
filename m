Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A9A1A6B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 20:26:09 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so275739pbb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 17:26:08 -0800 (PST)
Date: Wed, 29 Feb 2012 17:26:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: SLAB Out-of-memory diagnostics
In-Reply-To: <20120229032715.GA23758@t510.redhat.com>
Message-ID: <alpine.DEB.2.00.1202291724100.17729@chino.kir.corp.google.com>
References: <20120229032715.GA23758@t510.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Wed, 29 Feb 2012, Rafael Aquini wrote:

> Following the example at mm/slub.c, add out-of-memory diagnostics to the SLAB
> allocator to help on debugging OOM conditions. This patch also adds a new
> sysctl, 'oom_dump_slabs_forced', that overrides the effect of __GFP_NOWARN page
> allocation flag and forces the kernel to report every slab allocation failure.
> 
> An example print out looks like this:
> 
>   <snip page allocator out-of-memory message>
>   SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
>      cache: bio-0, object size: 192, order: 0
>      node0: slabs: 3/3, objs: 60/60, free: 0
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

I like it, except for the addition of the sysctl.  __GFP_NOWARN is used 
for a reason, usually because whatever is allocating memory can gracefully 
handle a failure and should not be emitted to the kernel log under any 
circumstances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
