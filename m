Date: Wed, 7 Nov 2007 10:30:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/23] SLUB: Add defrag_ratio field and sysfs support.
In-Reply-To: <20071107085545.GB6243@cataract>
Message-ID: <Pine.LNX.4.64.0711071030040.9857@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011228.102370371@sgi.com>
 <20071107085545.GB6243@cataract>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes-kernel@saeurebad.de>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007, Johannes Weiner wrote:

> Hi Christoph,
> 
> On Tue, Nov 06, 2007 at 05:11:37PM -0800, Christoph Lameter wrote:
> > --- linux-2.6.orig/include/linux/slub_def.h	2007-11-06 12:36:28.000000000 -0800
> > +++ linux-2.6/include/linux/slub_def.h	2007-11-06 12:37:44.000000000 -0800
> > @@ -53,6 +53,13 @@ struct kmem_cache {
> >  	void (*ctor)(struct kmem_cache *, void *);
> >  	int inuse;		/* Offset to metadata */
> >  	int align;		/* Alignment */
> > +	int defrag_ratio;	/*
> > +				 * objects/possible-objects limit. If we have
> > +				 * less that the specified percentage of
> 
> That should be `less than', I guess.

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
