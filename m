Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 46F346B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 05:33:56 -0500 (EST)
Received: by lagz14 with SMTP id z14so6264244lag.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 02:33:54 -0800 (PST)
Date: Mon, 5 Mar 2012 12:33:49 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm: SLAB Out-of-memory diagnostics
In-Reply-To: <20120302143323.GB1868@t510.redhat.com>
Message-ID: <alpine.LFD.2.02.1203051233440.1945@tux.localdomain>
References: <20120229032715.GA23758@t510.redhat.com> <alpine.DEB.2.00.1202291724100.17729@chino.kir.corp.google.com> <20120302143323.GB1868@t510.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Fri, 2 Mar 2012, Rafael Aquini wrote:

> On Wed, Feb 29, 2012 at 05:26:07PM -0800, David Rientjes wrote:
> > On Wed, 29 Feb 2012, Rafael Aquini wrote:
> > 
> > > Following the example at mm/slub.c, add out-of-memory diagnostics to the SLAB
> > > allocator to help on debugging OOM conditions. This patch also adds a new
> > > sysctl, 'oom_dump_slabs_forced', that overrides the effect of __GFP_NOWARN page
> > > allocation flag and forces the kernel to report every slab allocation failure.
> > > 
> > > An example print out looks like this:
> > > 
> > >   <snip page allocator out-of-memory message>
> > >   SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> > >      cache: bio-0, object size: 192, order: 0
> > >      node0: slabs: 3/3, objs: 60/60, free: 0
> > > 
> > > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > 
> > I like it, except for the addition of the sysctl.  __GFP_NOWARN is used 
> > for a reason, usually because whatever is allocating memory can gracefully 
> > handle a failure and should not be emitted to the kernel log under any 
> > circumstances.
> 
> Ok, I'll drop the sysctl part then. Pekka?

Yes, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
