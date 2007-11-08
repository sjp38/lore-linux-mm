Date: Thu, 8 Nov 2007 11:03:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 20/23] dentries: Add constructor
In-Reply-To: <20071108152324.GF2591@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711081101000.8954@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011231.453090374@sgi.com>
 <20071108152324.GF2591@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Mel Gorman wrote:

> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Seems to be some garbling on there in the signed-off lines.

Yes that needs to be fixed.

> > +void dcache_ctor(struct kmem_cache *s, void *p)
> > +{
> > +	struct dentry *dentry = p;
> > +
> > +	spin_lock_init(&dentry->d_lock);
> > +	dentry->d_inode = NULL;
> > +	INIT_LIST_HEAD(&dentry->d_lru);
> > +	INIT_LIST_HEAD(&dentry->d_alias);
> > +}
> > +
> 
> Is there any noticable overhead to the constructor?

Its a minor performance win since we can avoid reinitializing these
values and zeroing the object on alloc if there are already allocated 
objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
