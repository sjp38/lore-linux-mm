Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 08AA26B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:47:21 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so6948272iec.0
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:47:20 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id gi20si27794134icb.26.2014.06.17.14.47.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 14:47:20 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so6979518ieb.10
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:47:20 -0700 (PDT)
Date: Tue, 17 Jun 2014 14:47:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] slub: Use new node functions
In-Reply-To: <alpine.DEB.2.10.1406131055590.913@gentwo.org>
Message-ID: <alpine.DEB.2.02.1406171447010.27899@chino.kir.corp.google.com>
References: <20140611191510.082006044@linux.com> <20140611191519.070677452@linux.com> <alpine.DEB.2.02.1406111610130.27885@chino.kir.corp.google.com> <alpine.DEB.2.10.1406131055590.913@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 13 Jun 2014, Christoph Lameter wrote:

> On Wed, 11 Jun 2014, David Rientjes wrote:
> 
> > > +	for_each_kmem_cache_node(s, node, n) {
> > >
> > >  		free_partial(s, n);
> > >  		if (n->nr_partial || slabs_node(s, node))
> >
> > Newline not removed?
> 
> Ok got through the file and removed all the lines after
> for_each_kmem_cache_node.
> 
> >
> > > @@ -3407,11 +3401,7 @@ int __kmem_cache_shrink(struct kmem_cach
> > >  		return -ENOMEM;
> > >
> > >  	flush_all(s);
> > > -	for_each_node_state(node, N_NORMAL_MEMORY) {
> > > -		n = get_node(s, node);
> > > -
> > > -		if (!n->nr_partial)
> > > -			continue;
> > > +	for_each_kmem_cache_node(s, node, n) {
> > >
> > >  		for (i = 0; i < objects; i++)
> > >  			INIT_LIST_HEAD(slabs_by_inuse + i);
> >
> > Is there any reason not to keep the !n->nr_partial check to avoid taking
> > n->list_lock unnecessarily?
> 
> No this was simply a mistake the check needs to be preserved.
> 
> 
> Subject: slub: Fix up earlier patch
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Thanks!

Acked-by: David Rientjes <rientjes@google.com>

as merged in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
