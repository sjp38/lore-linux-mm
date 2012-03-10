Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BA3396B0044
	for <linux-mm@kvack.org>; Sat, 10 Mar 2012 03:48:20 -0500 (EST)
Received: by lbbgf7 with SMTP id gf7so716701lbb.14
        for <linux-mm@kvack.org>; Sat, 10 Mar 2012 00:48:18 -0800 (PST)
Date: Sat, 10 Mar 2012 10:48:12 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH v3] mm: SLAB Out-of-memory diagnostics
In-Reply-To: <alpine.DEB.2.00.1203091546360.2419@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1203101046510.1718@tux.localdomain>
References: <20120309202722.GA10323@x61.redhat.com> <alpine.DEB.2.00.1203091546360.2419@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>


> On Fri, 9 Mar 2012, Rafael Aquini wrote:
> 
> > Following the example at mm/slub.c, add out-of-memory diagnostics to the
> > SLAB allocator to help on debugging certain OOM conditions.
> > 
> > An example print out looks like this:
> > 
> >   <snip page allocator out-of-memory message>
> >   SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> >     cache: bio-0, object size: 192, order: 0
> >     node 0: slabs: 3/3, objs: 60/60, free: 0
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>

On Fri, 9 Mar 2012, David Rientjes wrote:
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Thanks for following through with this!

Applied, thanks guys!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
