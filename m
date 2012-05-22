Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B8D036B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 16:11:01 -0400 (EDT)
Date: Tue, 22 May 2012 13:10:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] scatterlist: add sg_alloc_table_from_pages function
Message-Id: <20120522131059.415a881c.akpm@linux-foundation.org>
In-Reply-To: <4FBA4ACE.4080602@samsung.com>
References: <4FA8EC69.8010805@samsung.com>
	<20120517165614.d5e6e4b6.akpm@linux-foundation.org>
	<4FBA4ACE.4080602@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: paul.gortmaker@windriver.com, =?UTF-8?Q?'=EB=B0=95=EA=B2=BD=EB=AF=BC'?= <kyungmin.park@samsung.com>, amwang@redhat.com, dri-devel@lists.freedesktop.org, "'???/Mobile S/W Platform Lab.(???)/E3(??)/????'" <inki.dae@samsung.com>, prashanth.g@samsung.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Rob Clark <rob@ti.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 21 May 2012 16:01:50 +0200
Tomasz Stanislawski <t.stanislaws@samsung.com> wrote:

> >> +int sg_alloc_table_from_pages(struct sg_table *sgt,
> >> +	struct page **pages, unsigned int n_pages,
> >> +	unsigned long offset, unsigned long size,
> >> +	gfp_t gfp_mask)
> > 
> > I guess a 32-bit n_pages is OK.  A 16TB IO seems enough ;)
> > 
> 
> Do you think that 'unsigned long' for offset is too big?
> 
> Ad n_pages. Assuming that Moore's law holds it will take
> circa 25 years before the limit of 16 TB is reached :) for
> high-end scatterlist operations.
> Or I can change the type of n_pages to 'unsigned long' now at
> no cost :).

By then it will be Someone Else's Problem ;)

> >> +{
> >> +	unsigned int chunks;
> >> +	unsigned int i;
> > 
> > erk, please choose a different name for this.  When a C programmer sees
> > "i", he very much assumes it has type "int".  Making it unsigned causes
> > surprise.
> > 
> > And don't rename it to "u"!  Let's give it a nice meaningful name.  pageno?
> > 
> 
> The problem is that 'i' is  a natural name for a loop counter.

It's also the natural name for an integer.  If a C programmer sees "i",
he thinks "int".  It's a Fortran thing ;)

> AFAIK, in the kernel code developers try to avoid Hungarian notation.
> A name of a variable should reflect its purpose, not its type.
> I can change the name of 'i' to 'pageno' and 'j' to 'pageno2' (?)
> but I think it will make the code less reliable.

Well, one could do something radical such as using "p".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
