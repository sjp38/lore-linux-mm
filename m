Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3F0FC6B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 21:50:58 -0400 (EDT)
Date: Thu, 20 Jun 2013 10:51:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
Message-ID: <20130620015118.GD13026@lge.com>
References: <20130614195500.373711648@linux.com>
 <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
 <20130619063037.GB12231@lge.com>
 <0000013f5cdb37c1-e49e6800-565f-4ff1-b8ca-3a00f75d388d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f5cdb37c1-e49e6800-565f-4ff1-b8ca-3a00f75d388d-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, Jun 19, 2013 at 02:33:57PM +0000, Christoph Lameter wrote:
> On Wed, 19 Jun 2013, Joonsoo Kim wrote:
> 
> > > +#ifndef CONFIG_SLOB
> > > +	if (__builtin_constant_p(size) &&
> > > +		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {
> >
> > s/SLAB_CACHE_DMA/GFP_DMA
> 
> Ok. Could you remove the rest of the email in the future? Its difficult to
> find your comment in the long diff.

Okay!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
