Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9C3C16B0072
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:17:35 -0500 (EST)
Date: Mon, 21 Nov 2011 11:17:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc 01/18] slub: Get rid of the node field
In-Reply-To: <alpine.DEB.2.00.1111201458520.30815@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1111211116550.4771@router.home>
References: <20111111200711.156817886@linux.com> <20111111200725.634567005@linux.com> <alpine.DEB.2.00.1111201458520.30815@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Sun, 20 Nov 2011, David Rientjes wrote:

> On Fri, 11 Nov 2011, Christoph Lameter wrote:
>
> > The node field is always page_to_nid(c->page). So its rather easy to
> > replace. Note that there will be additional overhead in various hot paths
> > due to the need to mask a set of bits in page->flags and shift the
> > result.
> >
>
> This certainly does add overhead to the fastpath just by checking
> node_match() if we're doing kmalloc_node(), and that overhead might be
> higher than you expect if NODE_NOT_IN_PAGE_FLAGS.  Storing the node in
> kmem_cache_cpu was always viewed as an optimization, not sure why you'd
> want to get rid of it?  The changelog at least doesn't mention any
> motivation.  Do we need to shrink that struct for something else later or
> something?

If you would read the description of the patch series you could probably
figure it out.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
