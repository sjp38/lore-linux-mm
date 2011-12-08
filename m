Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E10876B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:33:07 -0500 (EST)
Date: Thu, 8 Dec 2011 08:33:17 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v3 3/3] slub: min order when debug_guardpage_minorder > 0
Message-ID: <20111208073316.GA2402@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
 <1321633507-13614-3-git-send-email-sgruszka@redhat.com>
 <alpine.DEB.2.00.1112071407090.27360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112071407090.27360@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Wed, Dec 07, 2011 at 02:07:55PM -0800, David Rientjes wrote:
> On Fri, 18 Nov 2011, Stanislaw Gruszka wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 7d2a996..a66be56 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3645,6 +3645,9 @@ void __init kmem_cache_init(void)
> >  	struct kmem_cache *temp_kmem_cache_node;
> >  	unsigned long kmalloc_size;
> >  
> > +	if (debug_guardpage_minorder())
> > +		slub_max_order = 0;
> > +
> >  	kmem_size = offsetof(struct kmem_cache, node) +
> >  				nr_node_ids * sizeof(struct kmem_cache_node *);
> > 
> 
> I'd recommend at least printing a warning about why slub_max_order was 
> reduced because users may be concerned why they can't now change any 
> cache's order with /sys/kernel/slab/cache/order.

It's only happen with debug_guardpage_minorder=N parameter, so
perhaps I'll just document that in kernel-parameters.txt

Thanks
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
