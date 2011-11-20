Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4902A6B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 18:01:42 -0500 (EST)
Received: by iaek3 with SMTP id k3so8651856iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 15:01:38 -0800 (PST)
Date: Sun, 20 Nov 2011 15:01:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc 01/18] slub: Get rid of the node field
In-Reply-To: <20111111200725.634567005@linux.com>
Message-ID: <alpine.DEB.2.00.1111201458520.30815@chino.kir.corp.google.com>
References: <20111111200711.156817886@linux.com> <20111111200725.634567005@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, 11 Nov 2011, Christoph Lameter wrote:

> The node field is always page_to_nid(c->page). So its rather easy to
> replace. Note that there will be additional overhead in various hot paths
> due to the need to mask a set of bits in page->flags and shift the
> result.
> 

This certainly does add overhead to the fastpath just by checking 
node_match() if we're doing kmalloc_node(), and that overhead might be 
higher than you expect if NODE_NOT_IN_PAGE_FLAGS.  Storing the node in 
kmem_cache_cpu was always viewed as an optimization, not sure why you'd 
want to get rid of it?  The changelog at least doesn't mention any 
motivation.  Do we need to shrink that struct for something else later or 
something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
