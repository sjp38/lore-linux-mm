Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id AD55A6B004A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 09:36:26 -0500 (EST)
Date: Fri, 2 Mar 2012 11:33:24 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: SLAB Out-of-memory diagnostics
Message-ID: <20120302143323.GB1868@t510.redhat.com>
References: <20120229032715.GA23758@t510.redhat.com>
 <alpine.DEB.2.00.1202291724100.17729@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202291724100.17729@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Wed, Feb 29, 2012 at 05:26:07PM -0800, David Rientjes wrote:
> On Wed, 29 Feb 2012, Rafael Aquini wrote:
> 
> > Following the example at mm/slub.c, add out-of-memory diagnostics to the SLAB
> > allocator to help on debugging OOM conditions. This patch also adds a new
> > sysctl, 'oom_dump_slabs_forced', that overrides the effect of __GFP_NOWARN page
> > allocation flag and forces the kernel to report every slab allocation failure.
> > 
> > An example print out looks like this:
> > 
> >   <snip page allocator out-of-memory message>
> >   SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> >      cache: bio-0, object size: 192, order: 0
> >      node0: slabs: 3/3, objs: 60/60, free: 0
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> 
> I like it, except for the addition of the sysctl.  __GFP_NOWARN is used 
> for a reason, usually because whatever is allocating memory can gracefully 
> handle a failure and should not be emitted to the kernel log under any 
> circumstances.

Ok, I'll drop the sysctl part then. Pekka?

David, once again, thanks for your feedback!

  Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
