Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 699976B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:06:06 -0500 (EST)
Received: by iahk25 with SMTP id k25so4103628iah.14
        for <linux-mm@kvack.org>; Thu, 08 Dec 2011 13:06:05 -0800 (PST)
Date: Thu, 8 Dec 2011 13:06:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/3] slub: min order when debug_guardpage_minorder >
 0
In-Reply-To: <20111208073316.GA2402@redhat.com>
Message-ID: <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com> <1321633507-13614-3-git-send-email-sgruszka@redhat.com> <alpine.DEB.2.00.1112071407090.27360@chino.kir.corp.google.com> <20111208073316.GA2402@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Thu, 8 Dec 2011, Stanislaw Gruszka wrote:

> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 7d2a996..a66be56 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -3645,6 +3645,9 @@ void __init kmem_cache_init(void)
> > >  	struct kmem_cache *temp_kmem_cache_node;
> > >  	unsigned long kmalloc_size;
> > >  
> > > +	if (debug_guardpage_minorder())
> > > +		slub_max_order = 0;
> > > +
> > >  	kmem_size = offsetof(struct kmem_cache, node) +
> > >  				nr_node_ids * sizeof(struct kmem_cache_node *);
> > > 
> > 
> > I'd recommend at least printing a warning about why slub_max_order was 
> > reduced because users may be concerned why they can't now change any 
> > cache's order with /sys/kernel/slab/cache/order.
> 
> It's only happen with debug_guardpage_minorder=N parameter, so
> perhaps I'll just document that in kernel-parameters.txt
> 

SLUB will output a line in the dmesg that specifies the possible orders so 
it would be helpful to also note that those can change because of 
debug_guardpage_minorder in both Documentation/vm/slub.txt and the "order" 
file entry in Documentation/ABI/testing/sysfs-kernel-slab.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
