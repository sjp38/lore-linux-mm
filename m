Date: Mon, 3 Jan 2005 15:13:45 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: page migration\
Message-ID: <20050103171344.GD14886@logos.cnet>
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <20050103162406.GB14886@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050103162406.GB14886@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 03, 2005 at 02:24:06PM -0200, Marcelo Tosatti wrote:
> On Mon, Jan 03, 2005 at 01:04:35PM -0600, Ray Bryant wrote:
> > Dave Hansen wrote:
> > 
> > >
> > >>I'd like to see this order of patches become the new order for the memory
> > >>hotplug patch.  That way, I won't have to pull the migration patches out
> > >>of the hotplug patch every time a new one comes out (I need the migration
> > >>code, but not the hotplug code for a project I am working on.)
> > >>
> > >>Do you suppose this can be done???
> > >
> > >
> > >Absolutely.  I was simply working them in the order that they were
> > >implemented.  But, if we want the migration stuff merged first, I have
> > >absolutely no problem with putting it first in the patch set.  
> > >
> > >Next time I publish a tree, I'll see what I can do about producing
> > >similar rollups to what you have, with migration broken out from
> > >hotplug.
> > >
> > 
> > Cool.  Let me know if I can help at all with that.
> > 
> > Once we get that done I'd like to pursure getting the migration patches 
> > proposed for -mm and then mainline.  Does that make sense?
> > 
> > (perhaps it will make the hotplug patch easier to accept if we can get the 
> > memory migration stuff in first).
> > 
> > Of course, the "standalone" memory migration stuff makes most sense on 
> > NUMA, and there is some minor interface changes there to support that (i. 
> > e. consider:
> > 
> > migrate_onepage(page);
> > 
> > vs
> > 
> > migrate_onepage_node(page, node);
> > 
> > what the latter does is to call alloc_pages_node() instead of
> > page_cache_alloc() to get the new page.)

Memory migration makes sense for defragmentation too.

I think we enough arguments for merging the migration code first, as you suggest.

Its also easier to merge part-by-part than everything in one bunch.

Yes?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
