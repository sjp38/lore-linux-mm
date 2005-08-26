Date: Fri, 26 Aug 2005 08:24:57 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Zoned CART
In-Reply-To: <1125040173.20161.39.camel@twins>
Message-ID: <Pine.LNX.4.63.0508260824400.23210@cuia.boston.redhat.com>
References: <1123857429.14899.59.camel@twins>  <1124024312.30836.26.camel@twins>
 <1124141492.15180.22.camel@twins>  <43024435.90503@andrew.cmu.edu>
 <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
 <1125009555.20161.33.camel@twins>  <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
 <1125040173.20161.39.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Rahul Iyer <rni@andrew.cmu.edu>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Aug 2005, Peter Zijlstra wrote:

>  zone->present_pages - zone->free_pages = 
>                            zone->nr_active + zone->nr_inactive
> 
> Or is there some other place the pages can go?

Slab cache, page tables, ...

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
