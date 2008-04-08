Date: Tue, 8 Apr 2008 14:09:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 17/18] dentries: Add constructor
In-Reply-To: <20080407231402.63284bb5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081407550.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230229.678047976@sgi.com>
 <20080407231402.63284bb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> On Fri, 04 Apr 2008 16:02:15 -0700 Christoph Lameter <clameter@sgi.com> wrote:
> 
> > In order to support defragmentation on the dentry cache we need to have
> > a determined object state at all times.
> 
> Oh.  I don't recall seeing any previous changelog text or code comments
> which told us this, and which explained why?
> 
> I might have missed it.

There is prior docs and the code checks for the presence of a ctor 
for any defragmentable slab.

> > +void dcache_ctor(struct kmem_cache *s, void *p)
> > +{
> > +	struct dentry *dentry = p;
> > +
> > +	spin_lock_init(&dentry->d_lock);
> > +	dentry->d_inode = NULL;
> > +	INIT_LIST_HEAD(&dentry->d_lru);
> > +	INIT_LIST_HEAD(&dentry->d_alias);
> > +}
> 
> I don't think this needed global scope?

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
